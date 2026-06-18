-- Tabela com o MRR e status atualizado dos clientes.
-- Pega só a assinatura mais recente de cada um pra ter o valor atual, ignorando os registros antigos.

WITH mrr_rank AS (
SELECT
	c.cliente_id,
	c.nome_empresa,
	a.tipo_plano,
	a.valor_mensal,
	CASE
		WHEN a.data_cancelamento IS NOT NULL -- Se está preenchido, cancelou
			THEN 'Cancelado'
		ELSE 'Ativo'
	END AS status_assinatura,
	ROW_NUMBER() OVER( -- Assinatura mais recente receberá 1
		PARTITION BY c.cliente_id
		ORDER BY a.data_inicio DESC
	) AS ranking
FROM tb_assinaturas AS a

JOIN tb_clientes AS c
	ON c.cliente_id = a.cliente_id
)

SELECT
	mr.cliente_id,
	mr.nome_empresa,
	mr.tipo_plano,
	mr.valor_mensal,
	mr.status_assinatura
FROM mrr_rank AS mr

WHERE mr.ranking = 1 -- Apenas a assinatura mais recente
;