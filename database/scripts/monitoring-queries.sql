-- =========================================
-- PatoJogo - Queries de Monitoramento
-- =========================================
-- Queries úteis para monitorar o estado do banco de dados

-- =========================================
-- 1. RANKING GERAL
-- =========================================
-- Top 10 jogadores por pontuação
SELECT
  full_name as nome,
  score as pontuacao,
  progress_step as etapa,
  coins as moedas,
  created_at as data_cadastro
FROM public.profiles
ORDER BY score DESC
LIMIT 10;

-- =========================================
-- 2. ESTATÍSTICAS GERAIS
-- =========================================
-- Estatísticas gerais do sistema
SELECT
  COUNT(*) as total_usuarios,
  ROUND(AVG(score), 0) as media_pontuacao,
  ROUND(AVG(coins), 0) as media_moedas,
  SUM(score) as pontuacao_total,
  MAX(score) as maior_pontuacao,
  MIN(score) as menor_pontuacao
FROM public.profiles;

-- =========================================
-- 3. PROGRESSO DOS USUÁRIOS
-- =========================================
-- Usuários por etapa de progresso
SELECT
  progress_step as etapa,
  COUNT(*) as quantidade_usuarios,
  ROUND(AVG(score), 0) as media_pontuacao_etapa
FROM public.profiles
GROUP BY progress_step
ORDER BY progress_step;

-- =========================================
-- 4. ATIVIDADE RECENTE
-- =========================================
-- Usuários mais recentes (últimos 7 dias)
SELECT
  full_name as nome,
  score as pontuacao,
  created_at as data_cadastro
FROM public.profiles
WHERE created_at >= NOW() - INTERVAL '7 days'
ORDER BY created_at DESC;

-- =========================================
-- 5. TENTATIVAS DE QUIZ
-- =========================================
-- Estatísticas das tentativas por nível
SELECT
  level as nivel,
  COUNT(*) as total_tentativas,
  ROUND(AVG((summary->>'accuracy')::numeric), 1) as media_acertos,
  ROUND(AVG(total_score), 0) as media_pontuacao,
  ROUND(AVG(total_coins), 0) as media_moedas
FROM public.quiz_attempts
GROUP BY level
ORDER BY level;

-- =========================================
-- 6. LOJA - ITENS MAIS VENDIDOS
-- =========================================
-- Itens da loja e suas vendas
SELECT
  si.name as item_nome,
  si.category as categoria,
  si.price_coins as preco,
  COUNT(up.id) as vendas,
  si.is_available as disponivel
FROM public.store_items si
LEFT JOIN public.user_purchases up ON si.id = up.item_id
GROUP BY si.id, si.name, si.category, si.price_coins, si.is_available
ORDER BY vendas DESC;

-- =========================================
-- 7. CONQUISTAS POPULARES
-- =========================================
-- Conquistas mais desbloqueadas
SELECT
  achievement->>'label' as conquista,
  achievement->>'description' as descricao,
  COUNT(*) as vezes_desbloqueada
FROM public.quiz_progress,
LATERAL jsonb_array_elements(achievements) as achievement
GROUP BY achievement->>'label', achievement->>'description'
ORDER BY vezes_desbloqueada DESC;

-- =========================================
-- 8. PERFORMANCE DO SISTEMA
-- =========================================
-- Verificar tamanho das tabelas
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as tamanho_total,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as tamanho_tabela,
  n_tup_ins as inserts,
  n_tup_upd as updates,
  n_tup_del as deletes
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =========================================
-- 9. USUÁRIOS ATIVOS
-- =========================================
-- Usuários que fizeram tentativas recentemente
SELECT DISTINCT
  p.full_name as nome,
  p.score as pontuacao,
  MAX(qa.completed_at) as ultima_atividade
FROM public.profiles p
JOIN public.quiz_attempts qa ON p.id = qa.user_id
WHERE qa.completed_at >= NOW() - INTERVAL '30 days'
GROUP BY p.id, p.full_name, p.score
ORDER BY ultima_atividade DESC;

-- =========================================
-- 10. HEALTH CHECK
-- =========================================
-- Verificar integridade dos dados
SELECT
  'profiles_sem_progress' as check_name,
  COUNT(*) as quantidade
FROM public.profiles p
LEFT JOIN public.quiz_progress qp ON p.id = qp.user_id
WHERE qp.user_id IS NULL

UNION ALL

SELECT
  'progress_sem_profile' as check_name,
  COUNT(*) as quantidade
FROM public.quiz_progress qp
LEFT JOIN public.profiles p ON qp.user_id = p.id
WHERE p.id IS NULL

UNION ALL

SELECT
  'attempts_sem_profile' as check_name,
  COUNT(*) as quantidade
FROM public.quiz_attempts qa
LEFT JOIN public.profiles p ON qa.user_id = p.id
WHERE p.id IS NULL;

-- =========================================
-- FIM DAS QUERIES DE MONITORAMENTO
-- =========================================