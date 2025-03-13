#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pandas",
#     "plotly.express",
#     "tabulate",
#     "kaleido",
#     "numpy",
# ]
# ///

import io
import shutil
import subprocess
import pandas as pd
import numpy as np
import plotly.express as px

if __name__ == "__main__":
    subprocess.run(["zig", "build", "run", "-Doptimize=ReleaseFast", "--", "bench"]) 
    
    df = pd.read_csv("benchmark/timings.csv")

    avg_df = pd.DataFrame(columns=["year", "day", "avg"])

    for year in df["year"].unique():
        for day in df[df["year"] == year]["day"].unique():
            timings = df[(df["year"] == year) & (df["day"] == day)]["elapsed"].reset_index()["elapsed"]
            timings = timings.iloc[10:] / 1_000_000 # Warmup + conversion to ms
            row = [year, day, timings.mean()]
            avg_df.loc[len(avg_df)] = row

    avg_df["year"] = (avg_df["year"] + 2000).astype(np.int32)
    avg_df["day"] = avg_df["day"].astype(np.int32)

    total_time = avg_df["avg"].sum()
    
    fig = px.bar(avg_df, x="year", y="avg", text="day")
    fig.update_layout(xaxis_title='Year', yaxis_title='Time (ms)', xaxis_type='category')
    fig.update_layout(title_text=f'Total time: {total_time:.3f} ms', title_x=0.5)
    fig.update_layout(font=dict(size=18))
    fig.update_traces(textposition="inside", textangle=0)

    year_df = pd.DataFrame(columns= ["year", "sum"])

    for year in avg_df["year"].unique():
        row = [year, avg_df[avg_df["year"] == year]["avg"].sum()]
        year_df.loc[len(year_df)] = row
    year_df["year"] = year_df["year"].astype(np.int32)

    max = year_df["sum"].max()
    i = 0
    for index, row in year_df.iterrows():
        sum = row["sum"]
        fig.add_annotation(x=i, y=max*1.05, text=f'{sum:.2f} ms', showarrow=False, font=dict(size=18))
        i += 1
    
    fig.write_image("benchmark/graph.svg", width=1440, height=780)

    # Markdown exports
    buffer = io.StringIO()

    avg_df["avg"] = avg_df["avg"] * 1000 # to µs
    year_df["sum"] = year_df["sum"] * 1000 # to µs
    
    year_df.to_markdown(buffer, tablefmt="github", index=False, headers=["Year", "Time (µs)"], floatfmt=".0f")
    buffer.write("\n\n")
    avg_df.to_markdown(buffer, tablefmt="github", index=False, headers=["Year", "Day", "Time (µs)"], floatfmt=".0f")
    buffer.write("\n")

    with open("benchmark/tables.md", 'w') as file:
        buffer.seek(0)
        shutil.copyfileobj(buffer, file, -1)

    # Update README.md
    content = ""
    with open("README.md", "r") as file:
        content = file.read()

    index = content.find("# Benchmark")
    content = content[:index]

    buffer.seek(0)
    content = content + \
        "# Benchmark\n" + \
        "![Benchmark graph](https://github.com/Ad4u/aoc/blob/master/benchmark/graph.svg)\n\n" + \
        buffer.getvalue()

    with open("README.md", "w") as file:
        file.write(content)
