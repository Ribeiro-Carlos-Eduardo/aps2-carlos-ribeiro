APS 2 - Dossiê de Arquitetura Viva
Marketplace B2B de Sobras Industriais
Aluno: Carlos Ribeiro
Unidade Curricular: Modelagem de Software
Curso: Engenharia de Software
Modalidade: Avaliação Prática Supervisionada - APS 2

1. Funcionalidade Crítica Selecionada
Aceite de proposta de sobra industrial, separação da quantidade negociada e retenção do pagamento em custódia por meio de um gateway de Escrow.

2. Contexto
O Marketplace B2B de Sobras Industriais permite que empresas disponibilizem sobras industriais para negociação com outras empresas.

A funcionalidade selecionada compreende o processo iniciado pelo envio de uma proposta pela empresa compradora. O sistema valida a disponibilidade da sobra e registra a proposta para avaliação da empresa vendedora.

Após o aceite da proposta, a quantidade negociada é separada e uma transação de pagamento é criada em um gateway externo de Escrow. O objetivo é garantir maior segurança à negociação antes de sua conclusão.

3. Regras de Negócio
RN01: Uma negociação somente poderá ser concluída após o aceite de uma proposta válida.
RN02: Uma sobra industrial somente poderá ser negociada enquanto houver quantidade disponível.
RN03: O pagamento somente poderá ser efetuado após a separação das sobras negociadas.
4. Artefatos
Esta APS será composta pelos seguintes artefatos:

Diagrama de Sequência;
Diagrama de Atividades com Raias;
Diagrama de Transição de Estados;
Visão Arquitetural C4 - Nível 2;
ADR 0001 - Registro de Decisão Arquitetural.
