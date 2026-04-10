-- =========================================
-- PatoJogo - Dados de Teste
-- =========================================
-- Script para popular o banco com dados de teste
-- Execute apenas em ambiente de desenvolvimento

-- Limpar dados existentes (cuidado!)
-- DELETE FROM public.user_purchases;
-- DELETE FROM public.quiz_attempts;
-- DELETE FROM public.quiz_progress;
-- DELETE FROM public.profiles;

-- =========================================
-- 1. PERFIS DE TESTE
-- =========================================
INSERT INTO public.profiles (id, email, full_name, phone, progress_step, score, coins) VALUES
  ('550e8400-e29b-41d4-a716-446655440000', 'joao.silva@email.com', 'João Silva', '11987654321', 3, 1250, 450),
  ('550e8400-e29b-41d4-a716-446655440001', 'maria.santos@email.com', 'Maria Santos', '11987654322', 2, 980, 320),
  ('550e8400-e29b-41d4-a716-446655440002', 'pedro.oliveira@email.com', 'Pedro Oliveira', '11987654323', 4, 1450, 600),
  ('550e8400-e29b-41d4-a716-446655440003', 'ana.costa@email.com', 'Ana Costa', '11987654324', 1, 650, 180),
  ('550e8400-e29b-41d4-a716-446655440004', 'carlos.rodrigues@email.com', 'Carlos Rodrigues', '11987654325', 2, 890, 290),
  ('550e8400-e29b-41d4-a716-446655440005', 'julia.almeida@email.com', 'Julia Almeida', '11987654326', 3, 1100, 380),
  ('550e8400-e29b-41d4-a716-446655440006', 'marcos.lima@email.com', 'Marcos Lima', '11987654327', 1, 420, 120),
  ('550e8400-e29b-41d4-a716-446655440007', 'fernanda.souza@email.com', 'Fernanda Souza', '11987654328', 2, 780, 250),
  ('550e8400-e29b-41d4-a716-446655440008', 'roberto.castro@email.com', 'Roberto Castro', '11987654329', 3, 1320, 520),
  ('550e8400-e29b-41d4-a716-446655440009', 'patricia.mendes@email.com', 'Patricia Mendes', '11987654330', 1, 350, 90)
ON CONFLICT (id) DO NOTHING;

-- =========================================
-- 2. PROGRESSO DO QUIZ (PARA ALGUNS USUÁRIOS)
-- =========================================
INSERT INTO public.quiz_progress (
  user_id,
  unlocked_levels,
  level_progress,
  achievements,
  total_points,
  total_coins,
  completed_quiz_count
) VALUES
  ('550e8400-e29b-41d4-a716-446655440000', ARRAY['beginner', 'intermediate', 'advanced'], '{
    "beginner": {
      "averageAccuracy": 85,
      "bestScore": 450,
      "categoryStats": {"geografia": {"accuracy": 90, "correct": 18, "total": 20}},
      "completedCount": 20,
      "completedQuestions": [],
      "completionPercentage": 100,
      "correctCount": 17,
      "incorrectCount": 3,
      "lastAttemptDate": "2024-01-15T10:30:00Z",
      "skippedCount": 0,
      "totalCoins": 150,
      "totalQuestions": 20,
      "totalScore": 450
    },
    "intermediate": {
      "averageAccuracy": 78,
      "bestScore": 520,
      "categoryStats": {"historia": {"accuracy": 80, "correct": 16, "total": 20}},
      "completedCount": 18,
      "completedQuestions": [],
      "completionPercentage": 90,
      "correctCount": 14,
      "incorrectCount": 4,
      "lastAttemptDate": "2024-01-20T14:15:00Z",
      "skippedCount": 0,
      "totalCoins": 180,
      "totalQuestions": 20,
      "totalScore": 520
    },
    "advanced": {
      "averageAccuracy": 0,
      "bestScore": 0,
      "categoryStats": {},
      "completedCount": 0,
      "completedQuestions": [],
      "completionPercentage": 0,
      "correctCount": 0,
      "incorrectCount": 0,
      "lastAttemptDate": null,
      "skippedCount": 0,
      "totalCoins": 0,
      "totalQuestions": 20,
      "totalScore": 0
    }
  }'::jsonb, '[{"id": "primeiro-acerto", "label": "Primeiro acerto", "description": "Acertou sua primeira questão", "icon": "🎯", "unlockedAt": "2024-01-10T09:00:00Z"}]'::jsonb, 970, 330, 2),
  ('550e8400-e29b-41d4-a716-446655440001', ARRAY['beginner', 'intermediate'], '{
    "beginner": {
      "averageAccuracy": 92,
      "bestScore": 480,
      "categoryStats": {"ciencia": {"accuracy": 95, "correct": 19, "total": 20}},
      "completedCount": 20,
      "completedQuestions": [],
      "completionPercentage": 100,
      "correctCount": 18,
      "incorrectCount": 2,
      "lastAttemptDate": "2024-01-12T11:45:00Z",
      "skippedCount": 0,
      "totalCoins": 160,
      "totalQuestions": 20,
      "totalScore": 480
    },
    "intermediate": {
      "averageAccuracy": 0,
      "bestScore": 0,
      "categoryStats": {},
      "completedCount": 0,
      "completedQuestions": [],
      "completionPercentage": 0,
      "correctCount": 0,
      "incorrectCount": 0,
      "lastAttemptDate": null,
      "skippedCount": 0,
      "totalCoins": 0,
      "totalQuestions": 20,
      "totalScore": 0
    },
    "advanced": {
      "averageAccuracy": 0,
      "bestScore": 0,
      "categoryStats": {},
      "completedCount": 0,
      "completedQuestions": [],
      "completionPercentage": 0,
      "correctCount": 0,
      "incorrectCount": 0,
      "lastAttemptDate": null,
      "skippedCount": 0,
      "totalCoins": 0,
      "totalQuestions": 20,
      "totalScore": 0
    }
  }'::jsonb, '[{"id": "primeiro-acerto", "label": "Primeiro acerto", "description": "Acertou sua primeira questão", "icon": "🎯", "unlockedAt": "2024-01-08T16:20:00Z"}]'::jsonb, 480, 160, 1)
ON CONFLICT (user_id) DO NOTHING;

-- =========================================
-- 3. TENTATIVAS DE QUIZ (EXEMPLOS)
-- =========================================
INSERT INTO public.quiz_attempts (
  id,
  user_id,
  level,
  answers,
  summary,
  total_score,
  total_coins,
  status,
  started_at,
  completed_at
) VALUES
  ('attempt-001', '550e8400-e29b-41d4-a716-446655440000', 'beginner', '[]'::jsonb, '{
    "accuracy": 85,
    "correctCount": 17,
    "incorrectCount": 3,
    "skippedCount": 0,
    "totalTimeInSeconds": 450,
    "timePerQuestion": 22.5,
    "totalQuestions": 20,
    "stars": 3
  }'::jsonb, 425, 85, 'completed', '2024-01-15T10:00:00Z', '2024-01-15T10:30:00Z'),
  ('attempt-002', '550e8400-e29b-41d4-a716-446655440001', 'beginner', '[]'::jsonb, '{
    "accuracy": 92,
    "correctCount": 18,
    "incorrectCount": 2,
    "skippedCount": 0,
    "totalTimeInSeconds": 380,
    "timePerQuestion": 19,
    "totalQuestions": 20,
    "stars": 3
  }'::jsonb, 460, 92, 'completed', '2024-01-12T11:00:00Z', '2024-01-12T11:45:00Z')
ON CONFLICT (id) DO NOTHING;

-- =========================================
-- 4. COMPRAS DE LOJA (EXEMPLOS)
-- =========================================
INSERT INTO public.user_purchases (user_id, item_id) VALUES
  ('550e8400-e29b-41d4-a716-446655440000', 'powerup-dica-extra'),
  ('550e8400-e29b-41d4-a716-446655440002', 'theme-noite'),
  ('550e8400-e29b-41d4-a716-446655440005', 'cosmetic-borda-dourada')
ON CONFLICT (user_id, item_id) DO NOTHING;

-- =========================================
-- DADOS DE TESTE INSERIDOS COM SUCESSO!
-- =========================================