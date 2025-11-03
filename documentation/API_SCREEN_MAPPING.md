# 📱 Mapeo de Pantallas y APIs - QUHO

## Configuración de Entornos

### URLs Base
- **Desarrollo:** `http://localhost:8000/api/v1`
- **Producción:** `https://api.quhoapp.com/api/v1`

---

## 🔐 1. AUTENTICACIÓN

### 1.1 Splash Screen
**Pantalla:** `SplashPage`
**Ruta:** `/`

**APIs:**
- `GET /health/` - Verificar estado del servidor
- `GET /me/` - Verificar sesión actual (si hay token)

**Flujo:**
1. Verificar si hay token guardado
2. Si hay token → validar con `/me/`
3. Si token válido → Dashboard
4. Si no hay token o inválido → Login

---

### 1.2 Login
**Pantalla:** `LoginPage`
**Ruta:** `/login`

**APIs:**
- `POST /auth/login/`
  ```json
  Request:
  {
    "email": "user@example.com",
    "password": "password123"
  }
  
  Response:
  {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "first_name": "Juan",
      "last_name": "Pérez"
    }
  }
  ```

**Flujo:**
1. Usuario ingresa email y contraseña
2. Validar campos localmente
3. POST a `/auth/login/`
4. Guardar tokens en secure storage
5. Guardar datos de usuario
6. Si `onboarding_completed` = false → Onboarding
7. Si `onboarding_completed` = true → Dashboard

---

### 1.3 Registro
**Pantalla:** `RegisterPage`
**Ruta:** `/register`

**APIs:**
- `POST /auth/register/`
  ```json
  Request:
  {
    "email": "user@example.com",
    "password": "SecurePass123!",
    "password_confirm": "SecurePass123!",
    "first_name": "Juan",
    "last_name": "Pérez",
    "phone": "+52xxxxxxxxxx" (opcional)
  }
  
  Response:
  {
    "message": "Registro exitoso. Verifica tu email",
    "verification_required": true
  }
  ```

**Flujo:**
1. Usuario completa formulario
2. Validar todos los campos
3. POST a `/auth/register/`
4. Mostrar mensaje de verificación
5. Redirigir a pantalla de verificación

---

### 1.4 Verificación de Email
**Pantalla:** `EmailVerificationPage`
**Ruta:** `/verify-email`

**APIs:**
- `POST /auth/verify/`
  ```json
  Request:
  {
    "code": "123456"
  }
  
  Response:
  {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {...}
  }
  ```

**Flujo:**
1. Usuario recibe código por email
2. Ingresa código de 6 dígitos
3. POST a `/auth/verify/`
4. Guardar tokens
5. Ir a Onboarding

---

### 1.5 Recuperar Contraseña
**Pantallas:** `ForgotPasswordPage`, `ResetPasswordPage`

**APIs:**
- `POST /auth/password/reset/request/`
  ```json
  Request: { "email": "user@example.com" }
  Response: { "message": "Email enviado" }
  ```

- `POST /auth/password/reset/confirm/`
  ```json
  Request: {
    "token": "abc123",
    "password": "NewPass123!",
    "password_confirm": "NewPass123!"
  }
  Response: { "message": "Contraseña actualizada" }
  ```

---

## 🎯 2. ONBOARDING

### 2.1 Onboarding Conversacional
**Pantalla:** `OnboardingPage`
**Ruta:** `/onboarding`

**APIs:**
- `POST /onboarding/start/`
  ```json
  Response: {
    "session_id": "uuid",
    "current_step": "welcome",
    "progress": 0
  }
  ```

- `POST /onboarding/step/`
  ```json
  Request: {
    "session_id": "uuid",
    "step": "income",
    "data": { "monthly_income": 15000 }
  }
  Response: {
    "next_step": "expenses",
    "progress": 20,
    "ai_message": "¡Perfecto! Ahora cuéntame sobre tus gastos..."
  }
  ```

- `POST /onboarding/complete/`
  ```json
  Request: {
    "session_id": "uuid",
    "data": {
      "monthly_income": 15000,
      "fixed_expenses": [...],
      "savings_goal": 5000,
      "currency": "MXN"
    }
  }
  Response: {
    "user": { "onboarding_completed": true },
    "budget_id": "uuid",
    "goals_created": [...]
  }
  ```

**Pasos del Onboarding:**
1. **Welcome** - Bienvenida y explicación
2. **Income** - Ingreso mensual
3. **Fixed Expenses** - Gastos fijos (renta, servicios, etc.)
4. **Variable Expenses** - Promedio de gastos variables
5. **Savings** - Meta de ahorro mensual
6. **Goals** - Objetivos financieros
7. **Complete** - Resumen y creación de presupuesto inicial

---

## 🏠 3. DASHBOARD

### 3.1 Dashboard Principal
**Pantalla:** `DashboardPage`
**Ruta:** `/home/dashboard`

**APIs:**
- `GET /me/`
  ```json
  Response: {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "Juan",
    "plan": "free|premium",
    "level": 5,
    "points": 450
  }
  ```

- `GET /budget/{YYYY-MM}/summary/`
  ```json
  Response: {
    "month": "2024-01",
    "theoretical_income": 15000,
    "theoretical_expenses": 12000,
    "actual_income": 15500,
    "actual_expenses": 11200,
    "balance": 4300,
    "savings_rate": 28.7,
    "categories_breakdown": [
      {
        "category": "Alimentos",
        "budgeted": 3000,
        "spent": 2800,
        "percentage": 93.3
      }
    ]
  }
  ```

- `GET /transactions/?limit=5&ordering=-date`
  ```json
  Response: {
    "count": 150,
    "results": [
      {
        "id": "uuid",
        "type": "expense",
        "amount": 450.50,
        "category": "Alimentos",
        "description": "Supermercado",
        "date": "2024-01-15T14:30:00Z",
        "is_recurring": false
      }
    ]
  }
  ```

- `GET /gamification/points/summary/`
  ```json
  Response: {
    "total_points": 450,
    "level": 5,
    "next_level_points": 500,
    "streak_days": 12,
    "rank": "Bronze"
  }
  ```

**Widgets del Dashboard:**
1. **Hero Card** - Balance disponible + saludo personalizado
2. **Budget Progress** - Progreso del mes actual
3. **Recent Transactions** - Últimas 5 transacciones
4. **Gamification Badge** - Nivel y puntos
5. **Quick Actions** - Agregar transacción, ver presupuesto, etc.
6. **AI Insights** - Sugerencia del día (premium)

---

## 💰 4. FINANZAS

### 4.1 Transacciones
**Pantalla:** `TransactionsPage`
**Ruta:** `/home/transactions`

**APIs:**
- `GET /transactions/`
  ```json
  Query Params: ?page=1&limit=20&type=expense&category=Alimentos&start_date=2024-01-01&end_date=2024-01-31
  
  Response: {
    "count": 150,
    "next": "...",
    "previous": null,
    "results": [...]
  }
  ```

**Filtros:**
- Tipo (income/expense)
- Categoría
- Rango de fechas
- Monto mínimo/máximo
- Búsqueda por descripción

---

### 4.2 Agregar Transacción
**Pantalla:** `AddTransactionPage`
**Ruta:** `/home/add-transaction`

**APIs:**
- `GET /categories/`
  ```json
  Response: [
    { "id": "uuid", "name": "Alimentos", "type": "expense", "icon": "restaurant" },
    { "id": "uuid", "name": "Salario", "type": "income", "icon": "work" }
  ]
  ```

- `POST /transactions/`
  ```json
  Request: {
    "type": "expense",
    "amount": 450.50,
    "category_id": "uuid",
    "description": "Supermercado Walmart",
    "date": "2024-01-15T14:30:00Z",
    "is_recurring": false,
    "recurrence_pattern": null
  }
  
  Response: {
    "id": "uuid",
    "type": "expense",
    "amount": 450.50,
    "category": { "id": "uuid", "name": "Alimentos" },
    "description": "Supermercado Walmart",
    "date": "2024-01-15T14:30:00Z",
    "points_earned": 10
  }
  ```

**Flujo:**
1. Usuario selecciona tipo (ingreso/gasto)
2. Ingresa monto
3. Selecciona categoría
4. Agrega descripción (opcional)
5. Selecciona fecha
6. POST a `/transactions/`
7. Mostrar confirmación + puntos ganados
8. Actualizar lista de transacciones

---

### 4.3 Detalle de Transacción
**Pantalla:** `TransactionDetailPage`
**Ruta:** `/home/transaction/:id`

**APIs:**
- `GET /transactions/{id}/`
- `PATCH /transactions/{id}/`
- `DELETE /transactions/{id}/`

---

### 4.4 Presupuestos
**Pantalla:** `BudgetsPage`
**Ruta:** `/home/budgets`

**APIs:**
- `GET /budget/{YYYY-MM}/theoretical/`
  ```json
  Response: {
    "month": "2024-01",
    "total_income": 15000,
    "fixed_expenses": [
      { "concept": "Renta", "amount": 5000 }
    ],
    "variable_budget": 7000,
    "savings_target": 3000
  }
  ```

- `GET /budget/{YYYY-MM}/execution/`
  ```json
  Response: {
    "month": "2024-01",
    "actual_income": 15500,
    "actual_expenses": 11200,
    "by_category": [
      {
        "category": "Alimentos",
        "budgeted": 3000,
        "spent": 2800,
        "remaining": 200,
        "percentage": 93.3
      }
    ],
    "total_saved": 4300
  }
  ```

- `POST /budget/generate/`
  ```json
  Request: {
    "month": "2024-02"
  }
  Response: {
    "budget_id": "uuid",
    "message": "Presupuesto generado para Febrero 2024"
  }
  ```

**Flujo:**
1. Mostrar presupuesto del mes actual
2. Gráfica de progreso por categoría
3. Comparación teórico vs. ejecutado
4. Botón para ajustar presupuesto
5. Botón para generar siguiente mes

---

### 4.5 Metas de Ahorro
**Pantalla:** `GoalsPage`
**Ruta:** `/home/goals`

**APIs:**
- `GET /goals/`
  ```json
  Response: [
    {
      "id": "uuid",
      "name": "Fondo de Emergencia",
      "target_amount": 30000,
      "current_amount": 12000,
      "deadline": "2024-12-31",
      "progress": 40,
      "is_completed": false
    }
  ]
  ```

- `POST /goals/`
  ```json
  Request: {
    "name": "Vacaciones",
    "target_amount": 15000,
    "deadline": "2024-06-30",
    "priority": "high"
  }
  ```

- `POST /goals/{id}/contribute/`
  ```json
  Request: {
    "amount": 1000
  }
  Response: {
    "goal": {...},
    "new_progress": 45,
    "points_earned": 25
  }
  ```

---

### 4.6 Ingresos Fijos
**Pantalla:** `IncomesPage`

**APIs:**
- `GET /incomes/`
- `POST /incomes/`
- `PATCH /incomes/{id}/`
- `DELETE /incomes/{id}/`

```json
Modelo:
{
  "concept": "Salario",
  "amount": 15000,
  "recurrence": "monthly",
  "start_date": "2024-01-01"
}
```

---

### 4.7 Gastos Fijos
**Pantalla:** `FixedExpensesPage`

**APIs:**
- `GET /fixed-expenses/`
- `POST /fixed-expenses/`
- `PATCH /fixed-expenses/{id}/`
- `DELETE /fixed-expenses/{id}/`

```json
Modelo:
{
  "concept": "Renta",
  "amount": 5000,
  "category_id": "uuid",
  "recurrence": "monthly",
  "due_day": 5
}
```

---

## 🎮 5. GAMIFICACIÓN

### 5.1 Gamificación Principal
**Pantalla:** `GamificationPage`
**Ruta:** `/home/gamification`

**APIs:**
- `GET /gamification/points/summary/`
  ```json
  Response: {
    "total_points": 450,
    "level": 5,
    "level_name": "Intermedio",
    "next_level_points": 500,
    "points_to_next_level": 50,
    "streak_days": 12,
    "longest_streak": 28,
    "rank": "Bronze",
    "badges_unlocked": 8,
    "total_badges": 20
  }
  ```

- `GET /gamification/level/`
  ```json
  Response: {
    "level": 5,
    "name": "Intermedio",
    "perks": [
      "3 presupuestos personalizados",
      "10 consultas IA al mes",
      "Reportes básicos"
    ]
  }
  ```

**Widgets:**
1. **Level Card** - Nivel actual + barra de progreso
2. **Streak Counter** - Días consecutivos
3. **Points Summary** - Distribución de puntos
4. **Next Rewards** - Próximos logros

---

### 5.2 Desafíos
**Pantalla:** `ChallengesPage`
**Ruta:** `/home/challenges`

**APIs:**
- `GET /gamification/missions/active/`
  ```json
  Response: [
    {
      "id": "uuid",
      "title": "Ahorra $1000 esta semana",
      "description": "Reduce tus gastos y ahorra al menos $1000",
      "type": "weekly",
      "progress": 650,
      "target": 1000,
      "points_reward": 100,
      "deadline": "2024-01-21",
      "is_completed": false
    }
  ]
  ```

- `POST /gamification/missions/{id}/complete/`
  ```json
  Response: {
    "mission": {...},
    "points_earned": 100,
    "badge_unlocked": {
      "id": "uuid",
      "name": "Ahorrativo",
      "icon": "savings"
    }
  }
  ```

**Tipos de Desafíos:**
- **Diarios** - Registrar transacción, revisar presupuesto
- **Semanales** - Ahorrar X monto, no exceder presupuesto
- **Mensuales** - Cumplir meta de ahorro, categorizar todas las transacciones
- **Especiales** - Eventos, temporadas

---

### 5.3 Insignias
**Pantalla:** `BadgesPage`
**Ruta:** `/home/badges`

**APIs:**
- `GET /gamification/badges/`
  ```json
  Response: {
    "unlocked": [
      {
        "id": "uuid",
        "name": "Primer Paso",
        "description": "Registraste tu primera transacción",
        "icon": "star",
        "unlocked_at": "2024-01-10",
        "rarity": "common"
      }
    ],
    "locked": [
      {
        "id": "uuid",
        "name": "Maestro del Ahorro",
        "description": "Ahorra por 6 meses consecutivos",
        "icon": "trophy",
        "rarity": "legendary",
        "progress": 2,
        "target": 6
      }
    ]
  }
  ```

---

### 5.4 Racha (Streaks)
**APIs:**
- `GET /gamification/streaks/`
  ```json
  Response: {
    "current_streak": 12,
    "longest_streak": 28,
    "last_activity": "2024-01-15T10:30:00Z",
    "milestones": [7, 14, 30, 60, 90],
    "next_milestone": 14
  }
  ```

- `POST /gamification/streaks/bump/`
  ```json
  Response: {
    "streak": 13,
    "points_earned": 5,
    "message": "¡Racha de 13 días! Sigue así"
  }
  ```

---

## 🤖 6. AI ENGINE (Premium)

### 6.1 Chat con IA
**Pantalla:** `AIChatPage`
**Ruta:** `/home/ai-chat`

**APIs:**
- `POST /ai/chat/`
  ```json
  Request: {
    "message": "¿Cómo puedo ahorrar más este mes?",
    "context": {
      "month": "2024-01",
      "include_budget": true,
      "include_transactions": true
    }
  }
  
  Response: {
    "message_id": "uuid",
    "response": "Basándome en tus gastos de enero, te sugiero...",
    "suggestions": [
      { "category": "Entretenimiento", "current": 2000, "suggested": 1500 },
      { "category": "Comida fuera", "current": 1500, "suggested": 1000 }
    ],
    "quota_used": 5,
    "quota_remaining": 5
  }
  ```

**Límites:**
- Free: 10 mensajes/mes
- Premium: Ilimitado

---

### 6.2 Insights Mensuales
**APIs:**
- `GET /ai/insights/{YYYY-MM}/`
  ```json
  Response: {
    "month": "2024-01",
    "spending_pattern": "Has gastado 15% más en entretenimiento este mes",
    "savings_advice": "Podrías ahorrar $1000 más reduciendo gastos en...",
    "achievements": ["Mantuviste tu presupuesto de alimentos"],
    "warnings": ["Estás excediendo tu presupuesto de transporte"]
  }
  ```

---

### 6.3 Score Financiero
**APIs:**
- `GET /ai/score/{YYYY-MM}/`
  ```json
  Response: {
    "score": 78,
    "grade": "B+",
    "factors": {
      "savings_rate": { "score": 85, "weight": 30 },
      "budget_adherence": { "score": 75, "weight": 25 },
      "debt_management": { "score": 90, "weight": 20 },
      "financial_habits": { "score": 65, "weight": 25 }
    },
    "recommendations": [
      "Aumenta tu tasa de ahorro al 30%",
      "Reduce gastos variables en entretenimiento"
    ]
  }
  ```

---

## ⚙️ 7. CONFIGURACIÓN

### 7.1 Perfil
**Pantalla:** `ProfilePage`
**Ruta:** `/home/profile`

**APIs:**
- `GET /me/`
- `PATCH /me/`
  ```json
  Request: {
    "first_name": "Juan",
    "last_name": "Pérez",
    "phone": "+52xxxxxxxxxx",
    "currency": "MXN",
    "language": "es"
  }
  ```

---

### 7.2 Plan y Suscripción
**Pantalla:** `SubscriptionPage`
**Ruta:** `/home/subscription`

**APIs:**
- `GET /me/plan/`
  ```json
  Response: {
    "plan": "free",
    "features": {
      "budgets_limit": 3,
      "goals_limit": 2,
      "ai_queries_per_month": 10,
      "advanced_reports": false,
      "priority_support": false
    },
    "usage": {
      "budgets_used": 2,
      "goals_used": 1,
      "ai_queries_used": 5
    }
  }
  ```

- `POST /billing/checkout-session/`
  ```json
  Request: {
    "plan": "premium",
    "interval": "monthly"
  }
  Response: {
    "checkout_url": "https://checkout.stripe.com/...",
    "session_id": "cs_..."
  }
  ```

---

### 7.3 Seguridad
**Pantalla:** `SecurityPage`

**APIs:**
- `POST /auth/password/change/`
  ```json
  Request: {
    "current_password": "OldPass123!",
    "new_password": "NewPass456!",
    "new_password_confirm": "NewPass456!"
  }
  ```

- `GET /me/activity/`
  ```json
  Response: [
    {
      "action": "login",
      "ip": "192.168.1.1",
      "device": "iPhone 13",
      "timestamp": "2024-01-15T10:30:00Z"
    }
  ]
  ```

---

### 7.4 Notificaciones
**Pantalla:** `NotificationsPage`

**APIs:**
- `POST /push/register/`
  ```json
  Request: {
    "fcm_token": "xxxxx",
    "device_type": "android"
  }
  ```

- `GET /me/notification-settings/`
- `PATCH /me/notification-settings/`
  ```json
  {
    "budget_alerts": true,
    "goal_reminders": true,
    "transaction_confirmations": false,
    "marketing_emails": false
  }
  ```

---

## 📊 8. REPORTES (Premium)

### 8.1 Reporte Mensual
**APIs:**
- `GET /reports/monthly/{YYYY-MM}/`
  ```json
  Response: {
    "month": "2024-01",
    "income_total": 15500,
    "expense_total": 11200,
    "savings": 4300,
    "savings_rate": 27.7,
    "top_categories": [...],
    "comparison_previous_month": {...},
    "charts": {
      "spending_by_category": [...],
      "income_vs_expenses": [...]
    }
  }
  ```

---

## 🔔 9. SMS PARSER

### 9.1 Webhook para SMS
**API:**
- `POST /sms/ingest/`
  ```json
  Request: {
    "message_text": "BBVA: Compra por $450.00 en WALMART...",
    "received_at": "2024-01-15T14:30:00Z",
    "sender": "BBVA"
  }
  
  Response: {
    "transaction_id": "uuid",
    "parsed_data": {
      "type": "expense",
      "amount": 450.00,
      "merchant": "WALMART",
      "category_suggested": "Alimentos",
      "date": "2024-01-15T14:30:00Z"
    },
    "requires_confirmation": true
  }
  ```

**Flujo:**
1. SMS llega al dispositivo
2. App captura SMS de bancos
3. POST a `/sms/ingest/`
4. Backend parsea y crea transacción tentativa
5. Notificar al usuario para confirmar
6. Usuario confirma/edita transacción

---

## 🎯 PRIORIDADES DE IMPLEMENTACIÓN

### Fase 1 - MVP (Semana 1-2)
1. ✅ Sistema de diseño
2. ✅ Core utilities y networking
3. ✅ Rutas y navegación
4. 🔄 Autenticación (Login, Register, Verify)
5. 🔄 Onboarding básico
6. 🔄 Dashboard principal
7. 🔄 Transacciones (listar, agregar)

### Fase 2 - Core Features (Semana 3-4)
8. Presupuestos
9. Metas de ahorro
10. Categorías personalizadas
11. Gamificación básica
12. Perfil y configuración

### Fase 3 - Advanced (Semana 5-6)
13. AI Chat (Premium)
14. Insights y score financiero
15. SMS Parser
16. Reportes avanzados
17. Suscripción con Stripe

### Fase 4 - Polish (Semana 7-8)
18. Optimización de performance
19. Testing exhaustivo
20. Mejoras de UX
21. Documentación final

---

## 📝 NOTAS DE INTEGRACIÓN

### Manejo de Errores
Todos los endpoints pueden retornar:
```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "details": {}
}
```

Códigos de error comunes:
- `UNAUTHORIZED` (401)
- `FORBIDDEN` (403)
- `NOT_FOUND` (404)
- `VALIDATION_ERROR` (422)
- `QUOTA_EXCEEDED` (429)
- `SERVER_ERROR` (500)

### Paginación
Endpoints de listado usan paginación:
```
GET /endpoint/?page=1&limit=20
```

### Filtros y Ordenamiento
```
GET /transactions/?type=expense&category=Alimentos&ordering=-date
```

### Headers Requeridos
```
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

---

## 🔄 REFRESH TOKEN

Cuando un request retorna 401:
1. Intentar refresh automático
2. Si falla → logout y redirigir a login
3. Si funciona → reintentar request original

```
POST /auth/refresh/
{
  "refresh": "refresh_token"
}

Response:
{
  "access": "new_access_token"
}
```

