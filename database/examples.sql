# =========================================
# PatoJogo - Exemplos de Uso do Banco
# =========================================

-- =========================================
-- 1. CONSULTAS BÁSICAS
-- =========================================

-- Buscar perfil do usuário atual
SELECT * FROM public.profiles
WHERE id = auth.uid();

-- Buscar ranking (top 10)
SELECT full_name, score, progress_step
FROM public.profiles
ORDER BY score DESC
LIMIT 10;

-- Buscar progresso do quiz
SELECT * FROM public.quiz_progress
WHERE user_id = auth.uid();

-- =========================================
-- 2. INSERÇÕES TÍPICAS
-- =========================================

-- Nova tentativa de quiz
INSERT INTO public.quiz_attempts (
  id,
  user_id,
  level,
  answers,
  summary,
  total_score,
  total_coins,
  status
) VALUES (
  'attempt-' || gen_random_uuid(),
  auth.uid(),
  'beginner',
  '[]'::jsonb,
  '{"accuracy": 85, "correctCount": 17}'::jsonb,
  425,
  85,
  'completed'
);

-- Atualizar progresso do quiz
INSERT INTO public.quiz_progress (
  user_id,
  total_points,
  total_coins,
  completed_quiz_count
) VALUES (
  auth.uid(),
  425,
  85,
  1
) ON CONFLICT (user_id) DO UPDATE SET
  total_points = quiz_progress.total_points + 425,
  total_coins = quiz_progress.total_coins + 85,
  completed_quiz_count = quiz_progress.completed_quiz_count + 1,
  updated_at = timezone('utc', now());

-- =========================================
-- 3. LOJA
-- =========================================

-- Listar itens disponíveis
SELECT * FROM public.store_items
WHERE is_available = true
ORDER BY category, price_coins;

-- Verificar se usuário tem item
SELECT COUNT(*) > 0 as has_item
FROM public.user_purchases
WHERE user_id = auth.uid() AND item_id = 'powerup-dica-extra';

-- Comprar item
INSERT INTO public.user_purchases (user_id, item_id)
VALUES (auth.uid(), 'powerup-dica-extra');

-- =========================================
-- 4. ESTATÍSTICAS AVANÇADAS
-- =========================================

-- Progresso por categoria
SELECT
  level,
  jsonb_object_keys(level_progress) as category,
  (level_progress->jsonb_object_keys(level_progress)->>'accuracy')::numeric as accuracy
FROM public.quiz_progress
WHERE user_id = auth.uid();

-- Conquistas desbloqueadas
SELECT
  achievement->>'label' as label,
  achievement->>'description' as description,
  achievement->>'unlockedAt' as unlocked_at
FROM public.quiz_progress,
LATERAL jsonb_array_elements(achievements) as achievement
WHERE user_id = auth.uid();

-- =========================================
-- 5. QUERIES DE ADMINISTRAÇÃO
-- =========================================

-- Usuários mais ativos (últimos 30 dias)
SELECT
  p.full_name,
  COUNT(qa.id) as attempts_count,
  MAX(qa.completed_at) as last_activity
FROM public.profiles p
LEFT JOIN public.quiz_attempts qa ON p.id = qa.user_id
  AND qa.completed_at >= NOW() - INTERVAL '30 days'
GROUP BY p.id, p.full_name
HAVING COUNT(qa.id) > 0
ORDER BY attempts_count DESC;

-- Distribuição de pontuações
SELECT
  CASE
    WHEN score < 100 THEN '0-99'
    WHEN score < 500 THEN '100-499'
    WHEN score < 1000 THEN '500-999'
    WHEN score < 2000 THEN '1000-1999'
    ELSE '2000+'
  END as score_range,
  COUNT(*) as users_count
FROM public.profiles
GROUP BY score_range
ORDER BY score_range;

-- =========================================
-- EXEMPLOS DE USO COMPLETADOS
-- =========================================