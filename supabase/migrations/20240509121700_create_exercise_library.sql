-- Migration: Create Exercise Library Schema
-- Description: Sets up the exercise library schema with exercises table, triggers, indexes and RLS policies
-- Author: System
-- Date: 2024-05-09

-- Create the exercise_library schema
create schema if not exists exercise_library;

-- Create the exercises table
create table exercise_library.exercises (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    slug text not null,
    description text not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint exercises_name_unique unique (name),
    constraint exercises_slug_unique unique (slug)
);

-- Create the timestamp management function
create or replace function exercise_library.set_timestamp()
returns trigger as $$
begin
    if tg_op = 'INSERT' then
        new.created_at := now();
        new.updated_at := now();
    elsif tg_op = 'UPDATE' then
        new.updated_at := now();
    end if;
    return new;
end;
$$ language plpgsql;

-- Create the timestamp trigger
create trigger trg_set_timestamp
    before insert or update
    on exercise_library.exercises
    for each row
    execute function exercise_library.set_timestamp();

-- Create index on slug for faster lookups
create index idx_exercises_slug
    on exercise_library.exercises(slug);

-- Enable Row Level Security
alter table exercise_library.exercises enable row level security;

-- Create RLS Policies

-- Allow all users (both anon and authenticated) to read exercises
create policy select_exercises_anon
    on exercise_library.exercises
    for select
    to anon
    using (true);

create policy select_exercises_auth
    on exercise_library.exercises
    for select
    to authenticated
    using (true);

-- Block all modifications for regular users (admin-only operations)
create policy deny_modifications_anon
    on exercise_library.exercises
    for all
    to anon
    using (false);

create policy deny_modifications_auth
    on exercise_library.exercises
    for all
    to authenticated
    using (false);