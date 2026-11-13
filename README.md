<div align="center">

# 🗄️ Scripts para DBA
### SQL Server · Administração · Diagnóstico · Comunidade

**Uma coleção de scripts e referências para apoiar a rotina de administração de bancos de dados.**

Reunindo materiais que utilizei e utilizo no dia a dia, compartilhados para ajudar a comunidade de dados.

[Explore por tema](#explore-por-tema) · [Atalhos](#atalhos-para-consulta) · [Como utilizar](#como-utilizar-os-materiais) · [Leituras](#leituras-para-o-dia-a-dia) · [🎵 Música](#uma-pausa-na-rotina)

</div>

---

## Sobre a coleção

Este repositório reúne **scripts SQL, exemplos, anotações e materiais de apoio** para estudo e consulta na rotina de um DBA.

O foco principal é **Microsoft SQL Server**, com conteúdos sobre configuração, desempenho, índices, concorrência, segurança, integridade e recuperação. Há também materiais complementares de **PowerShell, Oracle e PostgreSQL**.

A coleção reúne contribuições e referências de diferentes épocas. Confira os comentários e créditos de cada arquivo para entender o contexto e a origem do material.

## Explore por tema

| Pasta | O que você encontra |
| --- | --- |
| [**0. Instalação e Configuração**](0.%20Instala%C3%A7%C3%A3o%20e%20Configura%C3%A7%C3%A3o/) | Configuração da instância, TEMPDB, Database Mail e Linked Server. |
| [**1. Rotinas Iniciais**](1.%20Rotinas%20Iniciais/) | Consultas iniciais, documentação e verificações do ambiente. |
| [**2. Analise e Criação de Índices**](2.%20Analise%20e%20Cria%C3%A7%C3%A3o%20de%20%C3%8Dndices/) | Análise, fragmentação e manutenção de índices. |
| [**3. Desempenho**](3.%20Desempenho/) | Conexões, processos, memória, TEMPDB e contadores. |
| [**4. Consistencia e Corrompido**](4.%20Consistencia%20e%20Corrompido/) | Verificações de integridade, DBCC e materiais de diagnóstico. |
| [**5. Concorrência**](5.%20Concorr%C3%AAncia/) | Bloqueios, concorrência e consultas relacionadas a I/O. |
| [**6. Segurança**](6.%20Seguran%C3%A7a/) | Usuários, logins, schemas e criptografia. |
| [**7. Scripts em PowerShell**](7.%20Scripts%20em%20PowerShell/) | Exemplos de automação com PowerShell. |
| [**8. Backup - Restore - Snapshot**](8.%20Backup%20-%20Restore%20-%20Snapshot/) | Backups, restaurações, modelos de recuperação e snapshots. |
| [**9. Otimizando T-SQL**](9.%20Otimizando%20T-SQL/) | Material de consulta e análise de logs de erro. |
| [**10. Dicas e Comandos Diversos - Parte 1**](10.%20Dicas%20e%20Comandos%20Diversos%20-%20Parte%201/) | Consultas, comandos e bases de exemplo. |
| [**10. Dicas e Comandos Diversos - Parte 2**](10.%20Dicas%20e%20Comandos%20Diversos%20-%20Parte%202/) | Exemplos adicionais de T-SQL e administração. |
| [**98. Oracle**](98.%20Oracle/) | Anotações, scripts e materiais de estudo sobre Oracle. |
| [**99. Postgres**](99.%20Postgres/) | Scripts, cursos e referências de PostgreSQL. |
| [**Livro TK 70-432**](Livro%20TK%2070-432/) | Exemplos históricos de estudo para administração do SQL Server. |

A numeração das pastas organiza a coleção por assunto; não representa uma sequência obrigatória de execução.

## Atalhos para consulta

| Necessidade | Ponto de partida |
| --- | --- |
| **Iniciar uma investigação de desempenho** | [Análise inicial de performance](1.%20Rotinas%20Iniciais/0.%20Analise%20Inicial%20-%20Performance.sql) |
| **Consultar conexões** | [Conexões do SQL Server](3.%20Desempenho/0.%20ConexoesSQLServer.sql) |
| **Investigar processos e bloqueios** | [Processos travados](3.%20Desempenho/0.%20ProcessosTravados.sql) |
| **Explorar o uso do TEMPDB** | [Análise do TEMPDB](3.%20Desempenho/1.%20AnaliseDoTempDB.sql) |
| **Consultar informações de tabelas** | [InfoTabelas_SQLServer.sql](InfoTabelas_SQLServer.sql) |
| **Consultar o histórico de backups** | [Backups realizados](8.%20Backup%20-%20Restore%20-%20Snapshot/Backups_Realizados.sql) |
| **Estudar operações de JOIN** | [Referência visual de SQL JOINs](0.%20_SQL%20JOINS.jpg) |
| **Explorar uma base de exemplo** | [Modelo AdventureWorks](AdventureWorks2008.gif) · [Modelo AdventureWorks DW](AdventureWorksDW2008.png) |

Os atalhos levam aos arquivos originais. Alguns scripts dependem de objetos auxiliares, configuração do banco ou adaptação de filtros; leia o arquivo completo antes de selecionar o trecho a executar.

## Como utilizar os materiais

1. **Defina o que deseja investigar.** Escolha a pasta correspondente ao problema ou ao tema de estudo.
2. **Leia o script e seus comentários.** Um mesmo arquivo pode reunir consultas, comandos de alteração e exemplos independentes.
3. **Adapte o contexto.** Confira banco selecionado, nomes de objetos, caminhos, parâmetros, filtros e permissões exigidas.
4. **Confira a compatibilidade.** Existem exemplos e referências de versões antigas, incluindo SQL Server 2000, 2005 e 2008. Recursos e permissões podem variar nas versões atuais.
5. **Valide o trecho em um ambiente de testes.** Para operações de manutenção, restauração ou mudança de configuração, avalie os efeitos e o procedimento de recuperação.
6. **Execute apenas o necessário e interprete o resultado.** Use a saída para orientar a investigação e compare com o comportamento do seu ambiente.

Para scripts T-SQL, utilize um cliente compatível, como o [SQL Server Management Studio — SSMS](https://learn.microsoft.com/sql/ssms/sql-server-management-studio-ssms). Arquivos de PowerShell, shell, documentos e materiais de outros SGBDs têm requisitos próprios.

**Atenção ao contexto:** a coleção inclui comandos que alteram o ambiente, como manutenção de índices, shrink e restore. A presença de um script no repositório não significa que ele seja uma recomendação de execução periódica ou automática.

## O papel do DBA

O **DBA — Database Administrator** atua na administração dos bancos de dados: instalação, configuração, atualização, monitoramento, controle de acesso e continuidade dos serviços.

Na prática, isso envolve equilibrar **disponibilidade, integridade, segurança, recuperação e desempenho**, considerando as necessidades de quem utiliza os dados.

[Leia mais sobre a atuação do DBA](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/dba/).

## Leituras para o dia a dia

Os materiais abaixo preservam as referências do README original. Os artigos refletem o contexto das respectivas publicações.

- [DBA CheckList](https://blogdozouza.wordpress.com/2012/06/02/dba-checklist-o-que-analisar-webcast/)
- [Ferramentas para DBA SQL Server](https://github.com/microsoft/tigertoolbox)
- [Banco de Dados corrompido](https://blogdozouza.wordpress.com/2012/01/14/analise-de-um-banco-de-dados-corrompido/)
- [Concorrência de Dados](https://blogdozouza.wordpress.com/2012/03/22/concorrencia-de-dados-sql-server/)
- [Transações no SQL Server](https://blogdozouza.wordpress.com/2008/11/16/transacoes-no-sql-server-commit-e-rollback-transaction/)
- [Arquitetura do Microsoft SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/arquitetura-no-sql-server/)
- [Instalação do Microsoft SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/instalacao-no-sql-server/)
- [Segurança no Microsoft SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/seguranca-no-sql-server/)
- [Performance / Desempenho no SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/desempenho/)
- [Alta Disponibilidade no SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/alta-disponibilidade-no-sql-server/)
- [Índices no SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/indices-no-sql-server/)
- [Erros no SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/erros-no-sql-server/)
- [Dicas de SQL Server](https://blogdozouza.wordpress.com/2012/07/27/dicas-de-sql-server-por-pinal-dave-ferramentas-dicas-e-videos/)
- [Mais dicas de SQL Server](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/relacionais/sql-server/materialdeapoio/)

### Documentação e comunidade

- [**Microsoft Learn — SQL Server**](https://learn.microsoft.com/sql/sql-server/) — documentação oficial do produto.
- [**Referência de T-SQL**](https://learn.microsoft.com/sql/t-sql/language-reference) — comandos e sintaxe.
- [**DMVs e funções de gerenciamento dinâmico**](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/system-dynamic-management-views) — referências para consultas de diagnóstico.
- [**Coletânea de blogs de banco de dados**](https://blogdozouza.wordpress.com/dados/estruturados/banco-de-dados/blogs/) — fontes para continuar estudando.

## Como contribuir

Encontrou um problema, tem uma sugestão ou deseja compartilhar uma melhoria? Abra uma **issue** ou envie um **pull request**.

Para facilitar a análise, descreva o objetivo, a versão do SGBD, os pré-requisitos e o comportamento esperado. Preserve os créditos dos materiais utilizados e substitua dados internos e credenciais por exemplos.

## Sobre o autor

**Alex Souza — liderança em dados e professor.**

Mestre em Ciência da Computação pela Universidade Estadual do Ceará, com foco em Inteligência Artificial e Processamento de Linguagem Natural (NLP). Especialista em Gestão de Banco de Dados e em Governança de TI pela Estácio FIC. Certificação MCTS em Implementação e Manutenção do SQL Server.

[Portfólio](https://omestredosdados.com.br/portfolio) · [Telegram — Mestre dos Dados](https://t.me/mestredosdados) · [O Mestre dos Dados](https://omestredosdados.com.br/)

---

<a id="uma-pausa-na-rotina"></a>

## 🎵 Uma pausa na rotina

Uma trilha sonora para acompanhar a leitura e os estudos.

[![Ouvir a música no YouTube](https://img.youtube.com/vi/vUR3J7btj3M/hqdefault.jpg)](https://www.youtube.com/watch?v=vUR3J7btj3M)

**[▶ Ouvir a música no YouTube](https://www.youtube.com/watch?v=vUR3J7btj3M)**
