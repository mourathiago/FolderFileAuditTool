## Script PowerShell para Análise de Arquivos e Pastas Recentemente Modificados ou Criados

Este script é projetado para ajudar a identificar arquivos e pastas que foram criados ou modificados nos últimos dias em um diretório especificado. 
É úteis para auditorias de sistema ou verificações de segurança.

## Requisitos

Windows PowerShell.

Permissões adequadas para acessar o diretório e seus subdiretórios.

### Instruções de Uso

1. Defina o caminho do diretório: Substitua ```C:``` na variável ```$rootPath``` pelo diretório que você deseja analisar.

2. Ajuste o período de análise: Modifique a variável ```$daysToAnalyze``` para alterar o número de dias de análise.

3. Execute o script: Salve o código em um arquivo com extensão ```.ps1``` e execute no PowerShell.

4. Confira o Relatório: O script gera um arquivo de relatório em texto ```(Relatorio_Modificacao_Criacao.txt)``` no diretório de trabalho atual.

## Verificação em dispositivos portáteis:

O script também pode ser utilizado para verificar dispositivos portáteis, como HDs externos e pendrives. Para isso, basta alterar o caminho do diretório ($rootPath) para a unidade desejada, como por exemplo, ```D:\``` ou ```E:\```.

## Observações

- Certifique-se de ter permissões suficientes para acessar os arquivos e pastas no diretório especificado.

- O script captura e ignora erros de acesso para evitar interrupções.

