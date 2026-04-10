#!/bin/bash

# =========================================
# PatoJogo - Script de Setup do Banco
# =========================================

echo "🐧 PatoJogo - Configuração do Banco de Dados"
echo "=========================================="
echo ""

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ] || [ ! -d "supabase" ]; then
    echo "❌ Erro: Execute este script do diretório raiz do projeto (patojogo/)"
    exit 1
fi

echo "📋 Instruções para aplicar as migrations:"
echo ""
echo "OPÇÃO 1 - Via Supabase CLI (Recomendado):"
echo "----------------------------------------"
echo "# 1. Instalar Supabase CLI (se não tiver)"
echo "npm install -g supabase"
echo ""
echo "# 2. Aplicar todas as migrations"
echo "supabase migration up"
echo ""
echo ""

echo "OPÇÃO 2 - Via SQL Editor do Supabase:"
echo "-------------------------------------"
echo "1. Acesse: https://supabase.com/dashboard"
echo "2. Selecione seu projeto 'patojogo'"
echo "3. Vá para 'SQL Editor'"
echo "4. Clique em 'New Query'"
echo "5. Execute os arquivos nesta ordem:"
echo ""

# Listar migrations na ordem correta
echo "📄 Arquivos de Migration (executar nesta ordem):"
echo ""

MIGRATIONS=(
    "20260409181525_create_profiles_and_progress.sql"
    "20260410000000_add_ranking_policy.sql"
    "20260410010000_complete_database_structure.sql"
)

for migration in "${MIGRATIONS[@]}"; do
    if [ -f "supabase/migrations/$migration" ]; then
        echo "✅ $migration"
        echo "   📍 supabase/migrations/$migration"
        echo ""
    else
        echo "❌ $migration (ARQUIVO NÃO ENCONTRADO)"
        echo ""
    fi
done

echo "🔧 Após executar as migrations:"
echo "-------------------------------"
echo "✅ Ranking funcionará automaticamente"
echo "✅ Sistema de pontuação integrado"
echo "✅ Loja pronta para implementação"
echo "✅ Progresso do quiz persistido"
echo ""

echo "🧪 Para testar:"
echo "---------------"
echo "# Verificar se usuários aparecem no ranking"
echo "SELECT full_name, score FROM profiles ORDER BY score DESC LIMIT 5;"
echo ""

echo "📚 Documentação completa: supabase/README.md"
echo ""
echo "🎉 Setup concluído! Execute as migrations no Supabase."