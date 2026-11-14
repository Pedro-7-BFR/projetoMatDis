import pandas as pd

df = pd.read_csv("dados/Sleep_health_and_lifestyle_dataset.csv", sep=";")

# limpeza
df = df.dropna()
df["BMI Category"] = df["BMI Category"].replace("Normal Weight", "Normal")
for coluna in ["Gender", "Occupation", "BMI Category"]:
    df[coluna] = df[coluna].str.lower().str.replace(" ", "_")

# gerar os fatos
with open("base.pl", "w") as f:
    for _, r in df.iterrows():
        a, b = r["Blood Pressure"].split("/")
        f.write(f"pessoa({r['Person ID']}, {r['Gender']}, {r['Age']}, {r['Occupation']}, "
                f"{r['Sleep Duration']}, {r['Quality of Sleep']}, {r['Physical Activity Level']}, "
                f"{r['Stress Level']}, {r['BMI Category']}, pressao({a},{b})).\n")