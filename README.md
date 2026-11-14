## Dataset

- **Fonte:** *Sleep Health and Lifestyle Dataset* (Kaggle): https://www.kaggle.com/datasets/uom190346a/sleep-health-and-lifestyle-dataset
- **Tabela usada:** Sleep_health_and_lifestyle_dataset.csv
- **Colunas:**

| Coluna | Tipo | Exemplo |
|---|---|---|
| Person ID | quantitativa (identificador) | 1 |
| Gender | qualitativa | male |
| Age | quantitativa | 27 |
| Occupation | qualitativa | software_engineer |
| Sleep Duration (horas) | quantitativa | 6.1 |
| Quality of Sleep (1 a 10) | quantitativa | 6 |
| Physical Activity Level (minutos/dia) | quantitativa | 42 |
| Stress Level (1 a 10) | quantitativa | 6 |
| BMI Category | qualitativa | overweight |
| Blood Pressure | quantitativa (2 valores) | 126/83 |


## Estrutura do repositório

```
.
├── README.md
├── requirements.txt
├── gerar_base.py     # ETL em Python: CSV -> base.pl
├── base.pl           # base de conhecimento (374 fatos)
├── perguntas.pl      # regras e perguntas em Prolog
└── dados/
    └── Sleep_health_and_lifestyle_dataset.csv
```


## Construção do projeto

1. **Escolha do dataset.** Procurei no Kaggle um dataset de uma única tabela, com 6 a 10 colunas e variáveis qualitativas e quantitativas, que permitisse agrupamentos.

2. **Seleção de colunas.** Selecionei 10 colunas do dataset original.

3. **ETL em Python (`gerar_base.py`).** O script lê o CSV (separador `;`) com pandas e faz a limpeza:
   - valores nulos caso existam são removidos com dropna();
   - as categorias "Normal" e "Normal Weight" de IMC foram unificadas em `normal`;
   - os textos viram constantes Prolog válidas (minúsculas, espaços trocados por `_`, por exemplo `Software Engineer` vira `software_engineer`);
   - a pressão arterial (`126/83`) é separada em dois números e escrita como o termo `pressao(126,83)`.

4. **Base de conhecimento (`base.pl`).** O script grava um fato por pessoa, no formato:

   ```prolog
   pessoa(1, male, 27, software_engineer, 6.1, 6, 42, 6, overweight, pressao(126,83)).
   ```

   Os argumentos são: id, gênero, idade, ocupação, horas de sono, qualidade do sono, atividade física, estresse, IMC e `pressao(p1, p2)`.

5. **Perguntas (`perguntas.pl`).** Regras e predicados auxiliares que respondem às quatro perguntas abaixo.

## Como rodar

**1. Gerar a base**

OBS: o requirements.txt nesse caso é somenta a biblioteca pandas, então se preferir
basta fazer: pip install pandas, ou então instala direto do requirements.txt

```bash
pip install -r requirements.txt
python gerar_base.py
```



**2. Para fazer as consultas use uma destas formas:**

1) **SWISH** (https://swish.swi-prolog.org/): crie um notebook, cole o conteúdo de `base.pl` e depois o de `perguntas.pl` na célula **Program**, e digite as consultas em uma célula **Query**

2) **SWI-Prolog local:**

  ```bash
  swipl base.pl perguntas.pl
  ```

  e digite as consultas no prompt. (Requer o SWI-Prolog instalado)

Teste rápido: `aggregate_all(count, pessoa(_,_,_,_,_,_,_,_,_,_), N).` deve retornar `N = 374`.

## Perguntas

### 1. Qual a média de qualidade do sono de cada ocupação? Qual o ranking?

Usa os predicados auxiliares `ocupacao/1` e `media/2`, `findall` para agrupar por ocupação, e `setof` + `reverse` para ordenar do maior para o menor.

```prolog
ranking_sono(R).
```

Resultado (valores aproximados):

| Posição | Ocupação | Média |
|---|---|---|
| 1 | engineer | 8,41 |
| 2 | lawyer | 7,89 |
| 3 | accountant | 7,89 |
| 4 | nurse | 7,37 |
| 5 | manager | 7,00 |
| 6 | teacher | 6,98 |
| 7 | doctor | 6,65 |
| 8 | software_engineer | 6,50 |
| 9 | salesperson | 6,00 |
| 10 | scientist | 5,00 |
| 11 | sales_representative | 4,00 |

### 2. Quais pessoas dormem menos que a média geral e têm estresse maior ou igual a 7?

Compara cada pessoa com a média geral de sono, calculada por uma regra auxiliar (`media_sono_geral/1`).

```prolog
sono_ruim_e_estressado(Id, Ocupacao).
aggregate_all(count, sono_ruim_e_estressado(_, _), N).
```

Resultado: **N = 120** pessoas. As ocupações mais frequentes nesse grupo são `nurse` (36), `doctor` (33) e `salesperson` (32).

### 3. Qual a média de horas de sono por categoria de IMC?

Mesma técnica da pergunta 1, agora agrupando por categoria de IMC.

```prolog
ranking_sono_imc(R).
```

Resultado: `normal` ≈ 7,39 h, `obese` ≈ 6,96 h e `overweight` ≈ 6,77 h.

### 4. Quais ocupações têm atividade física média acima da média geral?

Compara a média de cada ocupação com a média geral de atividade física (≈ 59,17 min/dia).

```prolog
setof(O, ocupacao_ativa(O), L).
```

Resultado: `L = [lawyer, nurse]`.