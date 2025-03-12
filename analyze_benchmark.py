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

if __name__ == "__main__":
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

    max = 0
    for year in avg_df["year"].unique():
        sum = avg_df[avg_df["year"] == year]["avg"].sum()
        if sum > max:
            max = sum
        
    i = 0
    for year in avg_df["year"].unique():
        sum = avg_df[avg_df["year"] == year]["avg"].sum()
        fig.add_annotation(x=i, y=max*1.05, text=f'{sum:.2f} ms', showarrow=False, font=dict(size=18))
        i += 1
    
    fig.write_image(f"benchmark/graph.svg", width=1440, height=780)
    fig.show()
