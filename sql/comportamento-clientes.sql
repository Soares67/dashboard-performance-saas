-- Resumo histórico do comportamento de cada cliente (acessos, tempo de uso e tickets).
-- Campos vazios recebem zero (menos o CSAT) pra garantir que a tabela traga a base inteira de clientes, com ou sem atividade.

WITH calendario AS (
	SELECT generate_series(
	        DATE_TRUNC('month', MIN(data_inicio)), -- Primeira data registrada na base
	        DATE_TRUNC('month', CURRENT_DATE), -- Data atual
	        '1 month'::interval -- Intervalos de um mês
	    )::date AS mes_referencia
	FROM tb_assinaturas
),

-- INFORMAÇÕES DE ACESSOS (Agrupadas por mês ao longo dos anos e por cliente)
info_acessos AS (
	SELECT
		c.mes_referencia,
		a.cliente_id,
		COUNT(a.acesso_id) AS total_acessos,
		ROUND(
			AVG(a.tempo_sessao_min)
		) AS tempo_medio_sessao
	FROM calendario AS c
	
	JOIN tb_acessos AS a
		ON DATE_TRUNC('month', a.data_login) = c.mes_referencia
	
	GROUP BY
		c.mes_referencia,
		a.cliente_id
),

-- INFORMAÇÕES DE SUPORTE (Agrupadas por mês ao longo dos anos e por cliente)
info_suporte AS (
	SELECT
		c.mes_referencia,
		s.cliente_id,
		COUNT(s.ticket_id) AS total_tickets, -- Todos os tickets
		COUNT(s.ticket_id)
			FILTER(WHERE s.categoria_ticket = 'Bug Crítico') -- Apenas tickets de bug crítico
		AS tickets_bug_critico,
		ROUND(
			AVG(s.avaliacao_csat)
		) AS csat_medio
	FROM calendario AS c
	
	JOIN tb_suporte AS s
		ON DATE_TRUNC('month', s.data_abertura) = c.mes_referencia
	
	GROUP BY
		c.mes_referencia,
		s.cliente_id
),

-- TABELA BASE (Todos os clientes, em todas as datas do calendário)
tabela_base AS (
	SELECT
		ca.mes_referencia,
		cl.cliente_id
	FROM tb_clientes AS cl
	CROSS JOIN calendario AS ca
)

-- Juntar as tabelas de informaçôes na tabela base
-- Se o cliente não tiver nenhum ticket ou acesso, atribuir 0
SELECT
	b.mes_referencia,
	b.cliente_id,
	COALESCE(a.total_acessos, 0) AS total_acessos,
	COALESCE(a.tempo_medio_sessao, 0) AS tempo_medio_sessao,
	COALESCE(s.total_tickets, 0) AS total_tickets,
	COALESCE(s.tickets_bug_critico, 0) AS tickets_bug_critico,
	s.csat_medio -- Manter null
FROM tabela_base AS b

-- Usar tanto as datas referência quanto os ids pra juntar as tabelas
LEFT JOIN info_acessos AS a
	ON a.cliente_id = b.cliente_id
	AND a.mes_referencia = b.mes_referencia
LEFT JOIN info_suporte AS s
	ON s.cliente_id = b.cliente_id
	AND s.mes_referencia = b.mes_referencia

ORDER BY b.mes_referencia ASC
;