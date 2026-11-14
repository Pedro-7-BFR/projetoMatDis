% Predicados auxiliares:
% media/2: calcula a média de uma lista de números (soma / tamanho).
% ocupacao/1: lista as ocupações da base (liga a variável para uso nos findall).
media(Lista, Media) :-
    sum_list(Lista, Soma),
    length(Lista, N),
    Media is Soma / N.

ocupacao(O) :- pessoa(_, _, _, O, _, _, _, _, _, _).


% Pergunta 1:
% Qual a média de qualidade do sono de cada ocupação? Qual o ranking?
% Técnica: findall + media/2 (auxiliar) para agrupar por ocupação,
%          setof + reverse para ordenar do maior para o menor.
% Consulta: ranking_sono(R).
qualidade_sono(O, Q) :- pessoa(_, _, _, O, _, Q, _, _, _, _).

media_qualidade(O, Media) :-
    ocupacao(O),
    findall(Q, qualidade_sono(O, Q), Lista),
    media(Lista, Media).

ranking_sono(Ranking) :-
    setof(Media-O, media_qualidade(O, Media), Lista),
    reverse(Lista, Ranking).


% Pergunta 2:
% Quais pessoas dormem menos que a média geral e têm estresse maior ou
% igual a 7?
% Técnica: comparação com a média geral, calculada por regra auxiliar
%          (media_sono_geral/1), combinada com um filtro de estresse.
% Consulta: sono_ruim_e_estressado(Id, Ocupacao).
% Contagem: aggregate_all(count, sono_ruim_e_estressado(_, _), N).

media_sono_geral(Media) :-
    findall(S, pessoa(_, _, _, _, S, _, _, _, _, _), Lista),
    media(Lista, Media).

sono_ruim_e_estressado(Id, Ocupacao) :-
    media_sono_geral(Media),
    pessoa(Id, _, _, Ocupacao, Sono, _, _, Estresse, _, _),
    Sono < Media,
    Estresse >= 7.


% Pergunta 3:
% Qual a média de horas de sono por categoria de IMC?
% Técnica: findall + media/2 (auxiliar) para agrupar por categoria de IMC,
%          setof + reverse para ordenar do maior para o menor.
% Consulta: ranking_sono_imc(R).
categoria_imc(C) :- pessoa(_, _, _, _, _, _, _, _, C, _).

sono_imc(C, S) :- pessoa(_, _, _, _, S, _, _, _, C, _).

media_sono_imc(C, Media) :-
    categoria_imc(C),
    findall(S, sono_imc(C, S), Lista),
    media(Lista, Media).

ranking_sono_imc(Ranking) :-
    setof(Media-C, media_sono_imc(C, Media), Lista),
    reverse(Lista, Ranking).


% Pergunta 4:
% Quais ocupações têm atividade física média acima da média geral?
% Técnica: composição de regras: a média de cada ocupação (media_atividade/2)
%          é comparada com a média geral (media_atividade_geral/1);
%          setof remove as repetições.
% Consulta: setof(O, ocupacao_ativa(O), L).
atividade(O, A) :- pessoa(_, _, _, O, _, _, A, _, _, _).

media_atividade(O, Media) :-
    ocupacao(O),
    findall(A, atividade(O, A), Lista),
    media(Lista, Media).

media_atividade_geral(Media) :-
    findall(A, pessoa(_, _, _, _, _, _, A, _, _, _), Lista),
    media(Lista, Media).

ocupacao_ativa(O) :-
    media_atividade(O, M),
    media_atividade_geral(G),
    M > G.