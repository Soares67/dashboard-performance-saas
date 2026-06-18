-- Cria o histórico de MRR mês a mês (ativos e cancelados) e a quantidade de clientes (ativos e cancelados).
-- Filtra pra pegar só a assinatura mais atual de cada cliente naquele mês, pra não somar o mesmo cliente duas vezes se ele trocou de plano.

WITH calendario AS (
    SELECT generate_series(
        DATE_TRUNC('month', MIN(data_inicio)), -- Primeira data registrada na base
        DATE_TRUNC('month', CURRENT_DATE), -- Data atual
        '1 month'::interval -- Intervalos de um mês
    )::date AS mes_referencia
    FROM tb_assinaturas
),
historico_clientes AS (
    SELECT 
        c.mes_referencia,
        a.cliente_id,
        a.valor_mensal,
		-- 
        CASE
			-- Se o mês de cancelamento e o mês de referência forem iguais, o cliente entra no churn
            WHEN DATE_TRUNC('month', a.data_cancelamento) = c.mes_referencia THEN 'Cancelado'
            ELSE 'Ativo'
        END AS status_assinatura,

		-- Rankeia as assinaturas da mais antiga para a mais recente (A mais recente receberá 1)
        ROW_NUMBER() OVER(
            PARTITION BY c.mes_referencia, a.cliente_id 
            ORDER BY a.data_inicio DESC
        ) as ranking
    FROM calendario c
    JOIN tb_assinaturas a 
        ON DATE_TRUNC('month', a.data_inicio) <= c.mes_referencia
		-- Garante que o mês do churn entre na lista
        AND (a.data_cancelamento IS NULL OR DATE_TRUNC('month', a.data_cancelamento) >= c.mes_referencia)
)
SELECT 
    hc.mes_referencia,
    COUNT(hc.cliente_id) FILTER(
		WHERE hc.status_assinatura = 'Ativo'
	) AS clientes_ativos,
	
    COUNT(hc.cliente_id) FILTER(
		WHERE hc.status_assinatura = 'Cancelado'
	) AS clientes_cancelados,
    
    COALESCE(
		SUM(valor_mensal) FILTER(WHERE hc.status_assinatura = 'Ativo'),
		0 -- Valor se nulo
	) as mrr_ativo,
	
    COALESCE(
		SUM(valor_mensal) FILTER(WHERE hc.status_assinatura = 'Cancelado'),
		0 -- Valor se nulo
	) as mrr_cancelado

FROM historico_clientes AS hc
WHERE ranking = 1 -- Filtra apenas as assinaturas mais recentes

GROUP BY hc.mes_referencia
ORDER BY hc.mes_referencia
;