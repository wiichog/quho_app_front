/**
 * Esquemas de validación con zod (port de validators.dart) + helpers reutilizables.
 * Mensajes en español, idénticos a la app original.
 */
import { z } from 'zod';

export const emailSchema = z
  .string()
  .min(1, 'El email es requerido')
  .regex(/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/, 'Email inválido');

export const passwordSchema = z
  .string()
  .min(1, 'La contraseña es requerida')
  .min(8, 'La contraseña debe tener al menos 8 caracteres')
  .regex(/[A-Z]/, 'Debe contener al menos una mayúscula')
  .regex(/[a-z]/, 'Debe contener al menos una minúscula')
  .regex(/[0-9]/, 'Debe contener al menos un número');

export const phoneSchema = z
  .string()
  .optional()
  .refine((v) => !v || v.replace(/\D/g, '').length === 10, 'El teléfono debe tener 10 dígitos');

export const amountSchema = z
  .string()
  .min(1, 'El monto es requerido')
  .refine((v) => {
    const n = parseFloat(v.replace(/,/g, ''));
    return !Number.isNaN(n) && n > 0;
  }, 'Monto inválido (debe ser mayor a 0)');

export const loginSchema = z.object({
  identifier: emailSchema,
  password: z.string().min(1, 'La contraseña es requerida'),
});

export const registerSchema = z
  .object({
    firstName: z.string().min(2, 'Ingresa tu nombre'),
    lastName: z.string().min(2, 'Ingresa tu apellido'),
    email: emailSchema,
    phone: phoneSchema,
    password: passwordSchema,
    passwordConfirm: z.string().min(1, 'Confirma tu contraseña'),
  })
  .refine((d) => d.password === d.passwordConfirm, {
    message: 'Las contraseñas no coinciden',
    path: ['passwordConfirm'],
  });

export const forgotPasswordSchema = z.object({ email: emailSchema });

export const transactionSchema = z.object({
  type: z.enum(['expense', 'income']),
  amount: amountSchema,
  categoryId: z.string().min(1, 'Selecciona una categoría').optional(),
  description: z.string().optional(),
  date: z.string().min(1, 'La fecha es requerida'),
});

export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;
export type ForgotPasswordInput = z.infer<typeof forgotPasswordSchema>;
export type TransactionInput = z.infer<typeof transactionSchema>;
