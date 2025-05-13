-- Migration: Create Profile Schema and Table
-- Description: Sets up the profile schema, profiles table, and associated RLS policies
-- Author: AI Assistant
-- Date: 2024-05-13

-- Create profile schema
create schema if not exists "profile";

-- Create profiles table
create table profile.profiles (
    id uuid primary key default gen_random_uuid(),
    owner_id uuid not null unique,
    age int,
    sex text,
    height_cm int,
    weight_kg int,
    experience_level text,
    limitations text,
    primary_goal text,
    available_equipment text[],
    session_length text,
    generation_params jsonb,
    deleted_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Create indexes
create index idx_profiles_deleted_at on profile.profiles (deleted_at);

-- Create updated_at trigger function
create or replace function profile.set_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Create trigger for updated_at
create trigger set_profiles_updated_at
    before update on profile.profiles
    for each row
    execute function profile.set_updated_at();

-- Enable Row Level Security
alter table profile.profiles enable row level security;

-- RLS Policies for authenticated users
create policy "select_own_profiles" on profile.profiles
    for select
    to authenticated
    using (auth.uid() = owner_id and deleted_at is null);

create policy "insert_own_profile" on profile.profiles
    for insert
    to authenticated
    with check (auth.uid() = owner_id);

create policy "update_own_profile" on profile.profiles
    for update
    to authenticated
    using (auth.uid() = owner_id);

-- RLS Policies for service role (admin access)
create policy "service_role_select" on profile.profiles
    for select
    to service_role
    using (true);

create policy "service_role_insert" on profile.profiles
    for insert
    to service_role
    with check (true);

create policy "service_role_update" on profile.profiles
    for update
    to service_role
    using (true);

create policy "service_role_delete" on profile.profiles
    for delete
    to service_role
    using (true);