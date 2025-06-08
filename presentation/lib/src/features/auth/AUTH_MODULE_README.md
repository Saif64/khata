# Khata App - Authentication Module

This document provides an overview of the authentication module, its setup, architecture, and API.

## 1. Setup Steps

### Prerequisites
*   Flutter SDK (version >=3.0.0) installed.
*   A Supabase account.

### Supabase Project Setup
1.  **Create a Supabase Project**: Go to [Supabase Dashboard](https://supabase.com/dashboard) and create a new project.
2.  **Get API Credentials**:
    *   Navigate to `Project Settings` > `API`.
    *   Copy your `Project URL` and `anon public` key.
3.  **Database Schema (`profiles` table)**:
    *   Go to `SQL Editor` in your Supabase project.
    *   Run the following SQL to create the `profiles` table, which stores user information linked to their authentication ID:
        ```sql
        CREATE TABLE public.profiles (
          id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
          name TEXT NOT NULL,
          phone TEXT UNIQUE NOT NULL, -- Ensure phone is unique if used as a primary login identifier with password
          email TEXT UNIQUE,
          profile_url TEXT,
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
        );

        -- Optional: Function and Trigger to automatically copy new users to profiles table
        -- This can be an alternative to inserting into profiles manually from the app after sign-up
        -- create function public.handle_new_user()
        -- returns trigger
        -- language plpgsql
        -- security definer set search_path = public
        -- as $$
        -- begin
        --   insert into public.profiles (id, phone, name) -- Add other default fields as necessary
        --   values (new.id, new.phone, new.raw_user_meta_data->>'name'); -- Assuming name is passed in metadata during signup
        --   return new;
        -- end;
        -- $$;

        -- create trigger on_auth_user_created
        --   after insert on auth.users
        --   for each row execute procedure public.handle_new_user();

        -- RLS Policies for profiles table (Example: Users can only see and manage their own profile)
        ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

        CREATE POLICY "Users can view their own profile."
          ON public.profiles FOR SELECT
          USING (auth.uid() = id);

        CREATE POLICY "Users can insert their own profile."
          ON public.profiles FOR INSERT
          WITH CHECK (auth.uid() = id);

        CREATE POLICY "Users can update their own profile."
          ON public.profiles FOR UPDATE
          USING (auth.uid() = id)
          WITH CHECK (auth.uid() = id);

        -- Note: If using phone + password sign-up where phone is stored in `auth.users.phone`,
        -- ensure `profiles.phone` is also populated correctly. The `handle_new_user` trigger example
        -- assumes phone might be part of `auth.users` or metadata. Adjust accordingly.
        -- If `phone` is not automatically in `auth.users` for phone+password signups (it typically is),
        -- the client-side insert into `profiles` (as implemented in `AuthRepositoryImpl`) is crucial.
        ```
    *   **Enable Phone Auth**: In Supabase Dashboard, go to `Authentication` > `Providers` and enable the `Phone` provider. Disable "Enable phone confirmations" if you don't want SMS verification for now (our current flow doesn't include OTP verification for phone, just uses it as an identifier with password). For actual phone number verification, you'd need to integrate an OTP step.

### Application Setup
1.  **Clone the Repository**: `git clone <repository_url>`
2.  **Create `.env` file**:
    *   In the `presentation` directory (`presentation/.env`), create a file named `.env`.
    *   Add your Supabase credentials:
        ```
        SUPABASE_URL=YOUR_SUPABASE_URL
        SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
        ```
3.  **Install Dependencies**:
    *   Navigate to the `presentation` directory: `cd presentation`
    *   Run `flutter pub get`
    *   Navigate to `data` directory: `cd ../data`
    *   Run `flutter pub get`
    *   Navigate to `domain` directory: `cd ../domain`
    *   Run `flutter pub get`
    *   Return to `presentation` directory: `cd ../presentation`
4.  **Run Build Runner (for DI)**:
    *   `flutter pub run build_runner build --delete-conflicting-outputs`
5.  **Run the App**:
    *   `flutter run`

## 2. Architecture Overview

The authentication module follows Clean Architecture principles, separating concerns into three layers:

*   **Domain Layer**:
    *   `UserEntity`: Defines the user model for the application.
    *   `AuthRepository` (Interface): Defines the contract for authentication operations (e.g., sign-up, sign-in, sign-out, get current user, auth state changes).
    *   `AuthFailure`: Represents different types of authentication errors.
*   **Data Layer**:
    *   `AuthRepositoryImpl`: Implements the `AuthRepository` interface, interacting with Supabase for authentication (using `supabase_flutter`) and storing/retrieving user profile data from the `profiles` table in Supabase.
*   **Presentation Layer**:
    *   `AuthBloc`: Manages the authentication state (`Authenticated`, `Unauthenticated`, `Loading`, `Failure`) and handles authentication events dispatched from the UI.
    *   **Screens**:
        *   `SignInScreen`: Allows users to sign in using their phone number and password.
        *   `SignUpScreen`: Allows new users to register with their name, phone number, password, and optional email/profile URL.
    *   **DI**: Dependency injection is managed using `get_it` and `injectable`.

## 3. API Contract (AuthRepository)

The `AuthRepository` interface (`domain/lib/src/repositories/auth_repository.dart`) defines the following methods:

*   `Future<Either<AuthFailure, UserEntity>> signUp({required String name, required String phone, required String password, String? email, String? profileUrl})`:
    Registers a new user with the provided details. On successful Supabase authentication, also creates a corresponding entry in the `profiles` table.

*   `Future<Either<AuthFailure, UserEntity>> signInWithPhone({required String phone, required String password})`:
    Signs in an existing user with their phone number and password. Fetches user details from the `profiles` table upon successful authentication.

*   `Future<Either<AuthFailure, void>> signOut()`:
    Signs out the currently authenticated user.

*   `Future<Either<AuthFailure, UserEntity?>> getCurrentUser()`:
    Retrieves the currently authenticated user, if any. Returns `null` if no user is signed in.

*   `Stream<UserEntity?> get authStateChanges`:
    A stream that emits the `UserEntity` when the authentication state changes (e.g., user signs in or out), or `null` if the user becomes unauthenticated.
```
