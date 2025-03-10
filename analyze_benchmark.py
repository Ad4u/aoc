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

import pandas as pd
import numpy as np
import plotly.express as px

def export_year_md(df, year):
    with open(f"benchmark/20{year}.md", 'w+') as f:
        df.mean().to_markdown(f, headers=["Solver", "Time (µs)"], floatfmt=".0f", tablefmt="github")
        f.write("\n")
        f.write("Total time: {:.2f} ms\n".format(df.mean().sum() / 1000))

def export_year_plot(df, year):
    max_val = max(df.max())
    total_avg = df.mean().sum() / 1000

    fig = px.box(df, points=False)
    fig.update_layout(xaxis_title='Solver', yaxis_title='Time (µs)')
    fig.update_layout(title_text=f'20{year} - Sum of average: {total_avg:.3f} ms', title_x=0.5)

    for i in range(len(df.columns)):
        fig.add_shape(type="line", x0=i, y0=-(max_val/20), x1=i, y1=max_val,
                      line=dict(color="rgba(0, 0, 0, 0.2)",
                      width=1,
                      dash="dot"))
        avg = df.mean().iloc[i]
        fig.add_annotation(x=i, y=0, text=f"{avg:.0f} µs", showarrow=False)

    fig.write_image(f"benchmark/20{year}.svg", width=1440, height=780)

if __name__ == "__main__":
    df = pd.read_csv("benchmark/timings.csv")

    total_df = pd.DataFrame(columns=["year", "sum_avg"])

    for year in df["year"].unique():
        year_df = pd.DataFrame()
        for day in df[df["year"] == year]["day"].unique():
            elapsed_col = df[(df["year"] == year) & (df["day"] == day)]["elapsed"].reset_index()["elapsed"]
            year_df[day] = elapsed_col / 1000 # to µs
            year_df = year_df.iloc[10:] # Warmup
        export_year_plot(year_df, year)
        export_year_md(year_df, year)

        row = [year, year_df.mean().sum()/1000]
        total_df.loc[len(total_df)] = row
        total_df["year"] = total_df["year"].astype(np.int64)

    total_time = total_df["sum_avg"].sum()
    with open(f"benchmark/total.md", 'w+') as f:
        total_df.to_markdown(f, headers=["Year", "Time (ms)"], floatfmt=".0f", tablefmt="github")
        f.write("\n")
        f.write(f"Total time: {total_time:.2f} ms\n")

    fig = px.bar(total_df, x='year', y='sum_avg')
    fig.update_layout(xaxis_title='Year', yaxis_title='Time (ms)', xaxis_type='category')
    fig.update_layout(title_text=f'Total time: {total_time:.3f} ms', title_x=0.5)
    fig.write_image(f"benchmark/total.svg", width=1440, height=780)
