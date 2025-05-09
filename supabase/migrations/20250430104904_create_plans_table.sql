-- Migration: create_plans_table
-- Description: Creates the initial plan_management schema and plans table with RLS policies
-- Author: System
-- Date: 2024-04-30

-- Create the plan_management schema
create schema if not exists plan_management;

-- Create plans table
create table plan_management.plans (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null,
  title text,
  training_days jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Add constraints for training_days JSON structure
alter table plan_management.plans add constraint chk_training_days_array 
  check (jsonb_typeof(training_days) = 'array');

alter table plan_management.plans add constraint chk_training_days_length 
  check (jsonb_array_length(training_days) <= 100);

-- Create function for automatic timestamp management
create or replace function plan_management.set_timestamp()
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

-- Create trigger for automatic timestamp management
create trigger trg_set_timestamp
  before insert or update
  on plan_management.plans
  for each row
  execute function plan_management.set_timestamp();

-- Create indexes for common query patterns
create index idx_plans_owner_active
  on plan_management.plans(owner_id)
  where deleted_at is null;

create index idx_plans_owner_updated_at
  on plan_management.plans(owner_id, updated_at desc);

-- Enable Row Level Security
alter table plan_management.plans enable row level security;

-- RLS Policies for authenticated users

-- SELECT: only active plans of the authenticated user
create policy select_own_plans
  on plan_management.plans
  for select
  to authenticated
  using (owner_id = auth.uid() and deleted_at is null);

-- INSERT: only with owner_id = auth.uid()
create policy insert_own_plans
  on plan_management.plans
  for insert
  to authenticated
  with check (owner_id = auth.uid());

-- UPDATE: only active plans of the owner
create policy update_own_plans
  on plan_management.plans
  for update
  to authenticated
  using (owner_id = auth.uid() and deleted_at is null)
  with check (owner_id = auth.uid());

-- DELETE: blocked via policy
create policy deny_delete
  on plan_management.plans
  for delete
  to authenticated
  using (false);

-- RLS Policies for anonymous users

-- Anonymous users cannot access any plans
create policy no_anon_select
  on plan_management.plans
  for select
  to anon
  using (false);

create policy no_anon_insert
  on plan_management.plans
  for insert
  to anon
  with check (false);

create policy no_anon_update
  on plan_management.plans
  for update
  to anon
  using (false)
  with check (false);

create policy no_anon_delete
  on plan_management.plans
  for delete
  to anon
  using (false);