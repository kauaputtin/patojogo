# 🗄️ Estrutura do Banco de Dados - PatoJogo

## 📋 Visão Geral

O banco de dados do PatoJogo foi estruturado para suportar um sistema completo de quiz educacional com ranking, loja e progresso do usuário.

## 🏗️ Arquitetura das Tabelas

### 1. **`profiles`** - Perfis dos Usuários
```sql
- id: UUID (chave primária, referência auth.users)
- email: TEXT (único)
- full_name: TEXT
- phone: TEXT (único, validado)
- progress_step: INTEGER (etapa atual no jogo)
- score: INTEGER (pontuação total)
- coins: INTEGER (moedas virtuais)
- created_at/updated_at: TIMESTAMPTZ
```

### 2. **`quiz_progress`** - Progresso do Quiz
```sql
- user_id: UUID (chave primária, referência auth.users)
- unlocked_levels: TEXT[] (níveis desbloqueados)
- level_progress: JSONB (progresso detalhado por nível)
- achievements: JSONB (conquistas desbloqueadas)
- total_points: INTEGER (pontos totais)
- total_coins: INTEGER (moedas totais)
- completed_quiz_count: INTEGER (quizzes completados)
- last_synced_at: TIMESTAMPTZ
```

### 3. **`quiz_attempts`** - Tentativas de Quiz
```sql
- id: TEXT (chave primária)
- user_id: UUID (referência auth.users)
- level: TEXT (beginner/intermediate/advanced)
- answers: JSONB (respostas da tentativa)
- summary: JSONB (estatísticas da tentativa)
- total_score/total_coins: INTEGER
- status: TEXT (completed/abandoned)
- started_at/completed_at: TIMESTAMPTZ
```

### 4. **`store_items`** - Itens da Loja
```sql
- id: TEXT (chave primária)
- name/description: TEXT
- price_coins: INTEGER
- category: TEXT (avatar/theme/powerup/cosmetic)
- image_url: TEXT
- is_available: BOOLEAN
```

### 5. **`user_purchases`** - Compras dos Usuários
```sql
- id: UUID (chave primária)
- user_id: UUID (referência auth.users)
- item_id: TEXT (referência store_items)
- purchased_at: TIMESTAMPTZ
```

## 🔄 Funcionalidades Automáticas

### Triggers Implementados:
- **`handle_new_user`**: Cria perfil automaticamente no registro
- **`handle_quiz_progress_change`**: Sincroniza score/coins com profiles
- **`set_updated_at`**: Atualiza timestamps automaticamente

### Sistema de Ranking:
- ✅ Score atualizado automaticamente via trigger
- ✅ Política RLS permite leitura pública para ranking
- ✅ Ordenação por pontuação descendente

## 🚀 Como Aplicar as Migrations

### Opção 1: Via Supabase CLI (Recomendado)
```bash
# Instalar CLI se necessário
npm install -g supabase

# Aplicar migrations
cd /workspaces/patojogo
supabase migration up
```

### Opção 2: Via SQL Editor do Supabase
1. Acesse https://supabase.com/dashboard
2. Selecione seu projeto `patojogo`
3. Vá para **SQL Editor**
4. Execute o conteúdo do arquivo:
   - `20260409181525_create_profiles_and_progress.sql`
   - `20260410000000_add_ranking_policy.sql`
   - `20260410010000_complete_database_structure.sql`

## 📊 Índices de Performance

Criados índices estratégicos para:
- Ranking por score (`profiles_score_idx`)
- Progresso por etapa (`profiles_progress_step_idx`)
- Tentativas por usuário/nível (`quiz_attempts_*_idx`)
- Pontos totais (`quiz_progress_total_points_idx`)

## 🔒 Segurança (RLS)

### Políticas Implementadas:
- **Perfis**: Leitura própria + leitura pública para ranking
- **Quiz Progress**: Apenas dono pode acessar/modificar
- **Quiz Attempts**: Apenas dono pode acessar
- **Loja**: Leitura pública, compras apenas próprias

## 🎯 Próximos Passos

Após aplicar as migrations:
1. ✅ Ranking funcionará automaticamente
2. ✅ Sistema de pontuação integrado
3. ✅ Loja pronta para implementação
4. ✅ Progresso do quiz persistido

## 📈 Monitoramento

Queries úteis para monitoramento:
```sql
-- Top 10 jogadores
SELECT full_name, score, progress_step
FROM profiles
ORDER BY score DESC
LIMIT 10;

-- Estatísticas gerais
SELECT
  COUNT(*) as total_users,
  AVG(score) as avg_score,
  SUM(score) as total_score
FROM profiles;
```