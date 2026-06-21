/**
 * Tipos de la API de QUHO. Derivados de los serializers reales del backend
 * (apps/users/serializers, apps/finances/serializers).
 */

// ---------- Auth / User ----------
export type OnboardingStatus =
  | 'incomplete'
  | 'in_progress'
  | 'functional'
  | 'complete'
  | string;

/** Usuario que regresa el login (apps/users/views/auth.py LoginView). */
export interface AuthUser {
  id: number | string;
  username: string;
  email: string;
  plan: string;
  onboarding_status: OnboardingStatus;
}

/** Perfil completo (GET /me/). */
export interface UserProfile {
  id: number | string;
  username: string;
  email: string;
  phone: string | null;
  first_name: string;
  last_name: string;
  currency: string;
  country?: string;
  onboarding_status?: OnboardingStatus;
  onboarding_completed_at?: string | null;
  created_at: string;
}

export interface AuthResponse {
  access: string;
  refresh: string;
  user: AuthUser;
}

export interface PlanQuotas {
  incomes: number | null;
  fixed_expenses: number | null;
  savings_accounts: number | null;
  goals: number | null;
  sms_ingestions_monthly: number | null;
  custom_categories: number | null;
}

export interface PlanUsage {
  incomes: number;
  fixed_expenses: number;
  savings_accounts: number;
  goals: number;
  sms_ingestions_monthly: number;
  custom_categories: number;
}

export interface UserPlan {
  plan: string;
  is_premium: boolean;
  trial_ends_at: string | null;
  premium_granted_days: number;
  quotas: PlanQuotas;
  usage: PlanUsage;
}

// ---------- Finances ----------
export type TxType = 'expense' | 'income';

export interface Category {
  id: number;
  slug: string;
  display_name: string;
  icon: string | null;
  color: string | null;
  parent_id: number | null;
  parent_name: string | null;
  full_path: string;
  is_system: boolean;
}

export interface Transaction {
  id: number;
  type: TxType;
  amount: string | number;
  category: number | null;
  category_name?: string | null;
  category_display?: { id: number; display_name: string; icon?: string; color?: string } | null;
  description: string | null;
  date: string;
  is_recurring?: boolean;
  created_at?: string;
}

export interface Income {
  id: number;
  name: string;
  amount: string | number;
  frequency: string;
  normalized_monthly: string | number;
  is_active: boolean;
  created_at: string;
}

export interface FixedExpense {
  id: number;
  name: string;
  amount: string | number;
  frequency: string;
  category_id: number | null;
  category_name: string | null;
  due_day: number | null;
  normalized_monthly: string | number;
  is_active: boolean;
}

export interface Goal {
  id: number;
  name: string;
  target_amount: string | number;
  current_amount: string | number;
  deadline: string | null;
  status: string;
  progress?: number;
}

export interface SavingsAccount {
  id: number;
  name: string;
  balance: string | number;
  is_active: boolean;
}

export interface BudgetCategoryRow {
  category: string;
  budgeted: number;
  spent: number;
  remaining?: number;
  percentage: number;
}

export interface BudgetSummary {
  month: string;
  theoretical_income?: number;
  theoretical_expenses?: number;
  actual_income?: number;
  actual_expenses?: number;
  balance?: number;
  savings_rate?: number;
  categories_breakdown?: BudgetCategoryRow[];
  [key: string]: unknown;
}

// ---------- Paginación DRF ----------
export interface Paginated<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

// ---------- Error normalizado ----------
export interface ApiError {
  status: number;
  message: string;
  fields?: Record<string, string[]>;
  raw?: unknown;
}
