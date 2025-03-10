#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "pandas",
#     "plotly.express",
#     "numpy",
#     "kaleido"
# ]
# ///

import pandas as pd
import plotly.express as px

df = pd.read_csv("benchmark/timings.csv")
df = df.iloc[10:] # Warmup

max_val = max(df.max())
total_avg = df.mean().sum() / 1000

fig = px.box(df, points=False, color_discrete_sequence=px.colors.qualitative.T10)
fig.update_layout(xaxis_title='Solver', yaxis_title='Time (µs)')
fig.update_layout(title_text=f'Timings - Sum of average: {total_avg:.3f} ms', title_x=0.5)
fig.update_xaxes(tickangle=285)

for i in range(len(df.columns)):
    fig.add_shape(type="line", x0=i, y0=-(max_val/20), x1=i, y1=max_val,
                  line=dict(color="rgba(0, 0, 0, 0.2)",
                  width=1,
                  dash="dot"))
    avg = df.mean().iloc[i]
    fig.add_annotation(x=i, y=avg+max_val/20, text=f"{avg:.0f}", textangle=270, showarrow=False)

fig.show()
# fig.write_html("benchmark/index.html")
# fig.write_image("benchmark/output.svg")
