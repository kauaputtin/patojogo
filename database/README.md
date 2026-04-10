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
4. Execute os arquivos nesta ordem:
   - `migrations/20260409181525_create_profiles_and_progress.sql`
   - `migrations/20260410000000_add_ranking_policy.sql`
   - `migrations/20260410010000_complete_database_structure.sql`

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

## 📁 Estrutura da Pasta

```
database/
├── README.md                    # Esta documentação
├── migrations/                  # Migrations SQL
│   ├── 20260409181525_create_profiles_and_progress.sql
│   ├── 20260410000000_add_ranking_policy.sql
│   └── 20260410010000_complete_database_structure.sql
├── schemas/                     # Tipos TypeScript
│   └── database.types.ts        # Tipos gerados do Supabase
└── scripts/                     # Scripts utilitários
    ├── setup-database.sh        # Script de setup automatizado
    ├── seed-test-data.sql       # Dados de teste
    └── monitoring-queries.sql   # Queries de monitoramento
```

## 📈 Monitoramento

Queries úteis para monitoramento estão em `scripts/monitoring-queries.sql`:
- Ranking geral
- Estatísticas do sistema
- Usuários por etapa
- Atividade recente
- Performance das tabelas
- Health checks

## 🧪 Dados de Teste

Para popular dados de teste, execute `scripts/seed-test-data.sql`:
- 10 perfis de teste com diferentes pontuações
- Progresso de quiz para alguns usuários
- Tentativas de exemplo
- Compras na loja

## 🔧 Manutenção

### Backup Regular:
```sql
-- Backup completo das tabelas principais
pg_dump -h [host] -U [user] -d [database] -t public.profiles -t public.quiz_progress -t public.quiz_attempts > backup.sql
```

### Limpeza de Dados Antigos:
```sql
-- Remover tentativas antigas (opcional)
DELETE FROM public.quiz_attempts
WHERE completed_at < NOW() - INTERVAL '1 year';
```

---

**🎉 Banco de dados completo e documentado! Pronto para uso em produção.**