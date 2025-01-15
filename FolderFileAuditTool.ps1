# Este script PowerShell analisa um diretório especificado para identificar arquivos e pastas criados ou modificados nos últimos sete dias.
# O script agora inclui a propriedade Usuario, que contém o proprietário do arquivo ou pasta.

# Caminho principal para análise
$rootPath = "C:\"  # Altere para o diretório desejado

# Número de dias para filtrar arquivos e pastas criados ou modificados
$daysToAnalyze = 7  

# Data limite para filtrar os arquivos e pastas
$dateLimit = (Get-Date).AddDays(-$daysToAnalyze)

# Inicializar lista para armazenar os resultados
$resultTxt = @()

# Exibir mensagem indicando início da análise
Write-Host "Iniciando análise no diretório: $rootPath"
Write-Host "Filtrando arquivos e pastas criados ou modificados após: $dateLimit"
Write-Host "----------------------------------------------------------------------"

# Verificar se o diretório existe
if (-Not (Test-Path -Path $rootPath)) {
    Write-Host "Erro: O diretório especificado não existe. Verifique o caminho: $rootPath" -ForegroundColor Red
    return
}

# Obter arquivos e pastas do diretório, incluindo subdiretórios
Get-ChildItem -Path $rootPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        # Tentar obter o proprietário do arquivo ou pasta
        $owner = $_.GetAccessControl().Owner
    } catch {
        # Caso ocorra um erro, definir proprietário como "Indisponível" e continuar
        $owner = "Indisponível"
        Write-Host "Erro ao acessar: $_.FullName. Ignorando..." -ForegroundColor Yellow
    }

    try {
        # Verificar se o item foi criado ou modificado dentro do período
        if ($_.CreationTime -ge $dateLimit) {
            # Evento de criação
            $resultTxt += [PSCustomObject]@{
                Evento           = "Criado"
                Tipo             = if ($_.PsIsContainer) { "Pasta" } else { "Arquivo" }
                DataHora         = $_.CreationTime.ToString('yyyy-MM-dd HH:mm:ss')
                Nome             = $_.Name
                CaminhoCompleto  = $_.FullName
                Usuario          = $owner
            }
        } elseif ($_.LastWriteTime -ge $dateLimit) {
            # Evento de modificação
            $resultTxt += [PSCustomObject]@{
                Evento           = "Modificado"
                Tipo             = if ($_.PsIsContainer) { "Pasta" } else { "Arquivo" }
                DataHora         = $_.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
                Nome             = $_.Name
                CaminhoCompleto  = $_.FullName
                Usuario          = $owner
            }
        }
    } catch {
        Write-Host "Erro ao processar: $_.FullName. Ignorando..." -ForegroundColor Yellow
    }
}

# Verificar se houve resultados
if ($resultTxt.Count -gt 0) {
    # Salvar relatório como .TXT com espaçamento organizado
    $reportTxtPath = Join-Path -Path (Get-Location) -ChildPath "Relatorio_Modificacao_Criacao.txt"
    
    # Adicionar cabeçalho manualmente
    $header = "Data e Hora         | Evento       | Tipo     | Nome                           | Caminho Completo                                     | Usuario"
    $line = '-' * 120

    $bodyTxt = $resultTxt | ForEach-Object {
        "{0,-20} | {1,-12} | {2,-8} | {3,-30} | {4,-50} | {5}" -f $_.DataHora, $_.Evento, $_.Tipo, $_.Nome, $_.CaminhoCompleto, $_.Usuario
    } | Out-String

    # Combinar cabeçalho e corpo
    $finalReport = "$header`n$line`n$bodyTxt"

    # Salvar o relatorio final no arquivo
    $finalReport.TrimEnd() | Out-File -FilePath $reportTxtPath -Encoding UTF8
    Write-Host "Relatório .TXT gerado com sucesso: $reportTxtPath" -ForegroundColor Green

    # Salvar o relatório como .xlsx (Excel)
    $reportExcelPath = Join-Path -Path (Get-Location) -ChildPath "Relatorio_Modificacao_Criacao.xlsx"

    # Criar o relatório Excel
    $resultTxt | Export-Excel -Path $reportExcelPath -AutoSize -TableName "RelatorioCriacaoModificacao" -WorksheetName "Arquivos Modificados e Criados"

    Write-Host "Relatório Excel (.xlsx) gerado com sucesso: $reportExcelPath" -ForegroundColor Green
} else {
    Write-Host "Nenhum arquivo ou pasta criado ou modificado nos últimos $daysToAnalyze dias foi encontrado no diretório $rootPath." -ForegroundColor Yellow
}


