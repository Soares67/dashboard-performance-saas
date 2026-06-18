# Métricas e Regras

Este documento resume as principais métricas e regras usadas no dashboard.

A ideia é deixar claro o que cada indicador representa e quais decisões foram tomadas na construção da análise.

---

## MRR Ativo

Receita recorrente mensal dos clientes ativos.

```text
MRR Ativo = soma do valor mensal dos clientes ativos
```

Usei essa métrica para acompanhar o volume de receita que ainda está ativo na base.

---

## MRR Cancelado

Receita recorrente associada aos clientes cancelados no período.

```text
MRR Cancelado = soma do valor mensal dos clientes cancelados no período
```

Essa métrica ajuda a medir o impacto financeiro dos cancelamentos.

---

## Base Ativa

Quantidade de clientes com assinatura ativa no período analisado.

```text
Base Ativa = total de clientes ativos
```

Ela serve como base para outras métricas, como ARPU, churn e base impactada.

---

## ARPU

Receita média por cliente ativo.

```text
ARPU = MRR Ativo / Base Ativa
```

Usei o ARPU para entender quanto, em média, cada cliente ativo representa em receita mensal.

---

## Taxa de Churn

Percentual de clientes cancelados em relação à base ativa.

```text
Taxa de Churn = Clientes Cancelados / Clientes Ativos
```

A métrica foi usada para acompanhar a perda de clientes ao longo do tempo e comparar o desempenho dos planos.

---

## CSAT Médio

Média das avaliações de satisfação registradas nos tickets de suporte.

```text
CSAT Médio = média das avaliações de CSAT
```

Quando o cliente não possui avaliação registrada, o valor não foi tratado como zero. Isso evita distorcer a média de satisfação.

---

## Base Impactada

Percentual da base ativa que teve pelo menos um ticket de bug crítico.

```text
Base Impactada = Clientes ativos com bug crítico / Clientes ativos
```

Essa métrica foi criada para medir o impacto dos bugs críticos sobre a base de clientes.

---

## Score de Risco dos Clientes

O score de risco foi criado para priorizar clientes que podem exigir atenção.

Ele considera dois fatores:

* quantidade de tickets de bug crítico;
* CSAT médio do cliente.

Clientes sem bug crítico e sem CSAT registrado não entram no ranking, pois não há sinal suficiente para avaliar risco.

### Pontuação por bugs críticos

| Tickets de Bug Crítico | Pontuação |
| ---------------------: | --------: |
|                      0 |         0 |
|                 1 a 10 |        10 |
|                11 a 25 |        20 |
|                26 a 40 |        30 |
|                41 a 54 |        40 |
|             55 ou mais |        50 |

### Pontuação por CSAT

|    CSAT Médio | Pontuação |
| ------------: | --------: |
|   4,5 ou mais |         0 |
|    4,0 a 4,49 |        10 |
|    3,5 a 3,99 |        20 |
|    3,0 a 3,49 |        30 |
|    2,5 a 2,99 |        40 |
| Abaixo de 2,5 |        50 |

### Classificação final

```text
Score de Risco = Pontuação por Bugs + Pontuação por CSAT
```

|        Score | Nível de Risco |
| -----------: | -------------- |
| Menor que 30 | Baixo          |
|   De 30 a 59 | Médio          |
|   60 ou mais | Alto           |

Essa regra é simples de interpretar e foi pensada para apoiar a priorização operacional, não para prever churn de forma estatística.

---

## Plano em destaque

O plano em destaque foi definido considerando principalmente:

* menor taxa de churn;
* receita relevante;
* bons níveis de satisfação.

---

## Eixo temporal dinâmico

O gráfico principal alterna automaticamente entre visão anual e mensal.

A regra usada foi:

```text
Sem ano selecionado → mostrar anos no eixo
Com ano selecionado → mostrar meses daquele ano
```

Isso permite usar um único gráfico para analisar tanto a visão geral por ano quanto o detalhe mensal de um ano específico.

---

## Tooltips personalizados

Foram criados tooltips para trazer mais detalhe sem poluir a tela principal.

### Tooltip por período

Mostra o resumo do mês ou ano selecionado no gráfico principal:

* MRR Ativo;
* Clientes Ativos;
* MRR Cancelado;
* Clientes Cancelados.

### Tooltip por plano

Mostra os principais indicadores do plano selecionado:

* MRR;
* Base Ativa;
* ARPU;
* participação na receita;
* churn;
* CSAT.

---

## Observação sobre os dados

Os dados foram estruturados em um banco PostgreSQL no Supabase.

As consultas SQL usadas na preparação das tabelas estão na pasta `sql/`. As credenciais e informações de conexão não foram incluídas no repositório.

