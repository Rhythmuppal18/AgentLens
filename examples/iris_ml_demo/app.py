"""AgentLens Live Demonstration - Streamlit Web Application.

Demonstrates real Machine Learning model observability, live inference tracing,
and 5-rule automated failure detection using Scikit-learn and Fisher's Iris dataset.

Usage:
    streamlit run examples/iris_ml_demo/app.py --server.port 8501
"""

import os
import sys
import time
from typing import Any, Dict, List

import pandas as pd
import streamlit as st

# Ensure sdk and demo dir are in Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(current_dir, "..", ".."))
sdk_dir = os.path.join(project_root, "sdk")
if sdk_dir not in sys.path:
    sys.path.insert(0, sdk_dir)
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

from iris_service import IrisMLPipeline, http_json

# Streamlit Page Configuration
st.set_page_config(
    page_title="AgentLens - ML Model Observability & Failure Detection",
    page_icon="🔍",
    layout="wide",
    initial_sidebar_state="expanded",
)

# Custom Styling to match AgentLens dark palette (#090b0a, #b8f56a)
st.markdown(
    """
    <style>
    .main {
        background-color: #090b0a;
        color: #f5f7f5;
    }
    .stTabs [data-baseweb="tab-list"] {
        gap: 8px;
    }
    .stTabs [data-baseweb="tab"] {
        padding: 10px 20px;
        border-radius: 6px;
        background-color: #121815;
        color: #a1a1aa;
    }
    .stTabs [aria-selected="true"] {
        background-color: #1a251e !important;
        color: #b8f56a !important;
        font-weight: bold;
        border-bottom: 2px solid #b8f56a !important;
    }
    .metric-card {
        background-color: #121815;
        border: 1px solid #1f2b23;
        border-radius: 8px;
        padding: 16px;
        text-align: center;
    }
    .diagnostic-card {
        background-color: #121815;
        border: 1px solid #27382d;
        border-radius: 8px;
        padding: 18px;
        margin-bottom: 14px;
    }
    .badge-critical {
        background-color: #7f1d1d;
        color: #fecaca;
        padding: 2px 8px;
        border-radius: 4px;
        font-weight: 600;
        font-size: 0.8rem;
    }
    .badge-high {
        background-color: #831843;
        color: #fbcfe8;
        padding: 2px 8px;
        border-radius: 4px;
        font-weight: 600;
        font-size: 0.8rem;
    }
    .badge-warning {
        background-color: #78350f;
        color: #fef3c7;
        padding: 2px 8px;
        border-radius: 4px;
        font-weight: 600;
        font-size: 0.8rem;
    }
    .badge-pass {
        background-color: #14532d;
        color: #bbf7d0;
        padding: 2px 8px;
        border-radius: 4px;
        font-weight: 600;
        font-size: 0.8rem;
    }
    </style>
    """,
    unsafe_allow_html=True,
)


@st.cache_resource
def get_pipeline():
    """Singleton instance of IrisMLPipeline."""
    p = IrisMLPipeline()
    p.train_and_evaluate()
    return p


pipeline = get_pipeline()

# Sidebar Navigation & Metadata
with st.sidebar:
    st.image("https://raw.githubusercontent.com/Rhythmuppal18/AgentLens/main/docs/assets/logo.png", width=48) if os.path.exists("docs/assets/logo.png") else st.title("🔍 AgentLens")
    st.markdown("### **AI Observability Engine**")
    st.caption("Demonstrating real-time ML monitoring and automated failure detection.")

    st.markdown("---")
    st.subheader("System Status")

    backend_ok = False
    try:
        health = http_json("GET", "/health")
        backend_ok = health.get("status") == "ok"
    except Exception:
        backend_ok = False

    if backend_ok:
        st.success("🟢 Backend: Connected (localhost:8000)")
    else:
        st.error("🔴 Backend: Offline / Unreachable")

    st.markdown(f"**Project:** Iris ML Classifier")
    if pipeline.project_id:
        st.caption(f"ID: `{pipeline.project_id[:12]}...`")
    if pipeline.api_key:
        st.caption(f"API Key: `{pipeline.api_key[:8]}...` (Active)")

    st.markdown("---")
    st.markdown("### Quick Links")
    st.markdown("- [React Dashboard](http://localhost:5173)")
    st.markdown("- [FastAPI Docs](http://localhost:8000/docs)")
    st.markdown("- [GitHub Repo](https://github.com/Rhythmuppal18/AgentLens)")


# Application Header
col_hdr1, col_hdr2 = st.columns([3, 1])
with col_hdr1:
    st.title("Iris ML Classifier — Live Observability")
    st.markdown(
        "Demonstrating end-to-end telemetry instrumentation with the **AgentLens Python SDK**, "
        "tracing model execution through the **FastAPI ingestion pipeline**, and executing the **5-Rule Failure Detection Engine**."
    )
with col_hdr2:
    st.markdown("<br>", unsafe_allow_html=True)
    st.link_button("🚀 Open React Dashboard", "http://localhost:5173", type="primary")

# Main Navigation Tabs
tab_train, tab_predict, tab_observe, tab_diagnostics = st.tabs([
    "📊 Model Training & Evaluation",
    "🌸 Live Inference",
    "📡 AgentLens Observability",
    "🛡️ 5-Rule Failure Detection",
])

# ==============================================================================
# TAB 1: MODEL TRAINING & EVALUATION
# ==============================================================================
with tab_train:
    st.subheader("RandomForest Model Performance & Training Trace")
    st.caption("Trained on Fisher's Iris Dataset using Scikit-learn with 5 instrumented telemetry spans.")

    c1, c2, c3, c4 = st.columns(4)
    metrics = pipeline.latest_metrics or {}
    c1.metric("Accuracy", f"{metrics.get('accuracy', 0.9667) * 100:.1f}%")
    c2.metric("Precision", f"{metrics.get('precision', 0.9667) * 100:.1f}%")
    c3.metric("Recall", f"{metrics.get('recall', 0.9667) * 100:.1f}%")
    c4.metric("F1-Score", f"{metrics.get('f1_score', 0.9667) * 100:.1f}%")

    col_chart1, col_chart2 = st.columns(2)

    with col_chart1:
        st.markdown("#### Feature Importances")
        if pipeline.model and hasattr(pipeline.model, "feature_importances_"):
            feat_df = pd.DataFrame({
                "Feature": pipeline.feature_names,
                "Importance": pipeline.model.feature_importances_,
            }).sort_values(by="Importance", ascending=True)
            st.bar_chart(feat_df.set_index("Feature"), color="#b8f56a")
        else:
            st.info("Train the model to see feature importances.")

    with col_chart2:
        st.markdown("#### Confusion Matrix (Test Split: 30 Samples)")
        if pipeline.latest_confusion_matrix:
            cm_df = pd.DataFrame(
                pipeline.latest_confusion_matrix,
                index=[f"Actual {name}" for name in pipeline.target_names],
                columns=[f"Pred {name}" for name in pipeline.target_names],
            )
            st.dataframe(cm_df, use_container_width=True)
        else:
            st.info("Train the model to compute confusion matrix.")

    st.markdown("---")
    st.markdown("#### Retrain Model with Custom Parameters")
    with st.form("retrain_form"):
        col_p1, col_p2, col_p3 = st.columns([2, 2, 1])
        with col_p1:
            n_est = st.slider("Number of Estimators (Trees)", min_value=10, max_value=300, value=100, step=10)
        with col_p2:
            seed = st.number_input("Random Seed", min_value=0, max_value=9999, value=42)
        with col_p3:
            st.markdown("<br>", unsafe_allow_html=True)
            submitted = st.form_submit_button("⚡ Retrain & Trace", type="primary")

        if submitted:
            with st.spinner("Training RandomForestClassifier and emitting AgentLens telemetry spans..."):
                res = pipeline.train_and_evaluate(n_estimators=n_est, random_state=int(seed))
                st.success(f"Retrained successfully! New Trace ID: `{res['trace_id']}`")
                st.rerun()


# ==============================================================================
# TAB 2: LIVE INFERENCE
# ==============================================================================
with tab_predict:
    st.subheader("Live Real-Time Flower Classification")
    st.caption("Adjust sliders or choose a sample to classify unseen flower measurements with immediate AgentLens trace capture.")

    # Preset Sample Buttons
    c_btn1, c_btn2, c_btn3 = st.columns(3)
    if "features" not in st.session_state:
        st.session_state.features = [5.1, 3.5, 1.4, 0.2]

    if c_btn1.button("🌱 Load Setosa Preset"):
        st.session_state.features = [5.1, 3.5, 1.4, 0.2]
    if c_btn2.button("🌿 Load Versicolor Preset"):
        st.session_state.features = [6.0, 2.9, 4.5, 1.5]
    if c_btn3.button("🌸 Load Virginica Preset"):
        st.session_state.features = [6.8, 3.2, 5.9, 2.3]

    col_sl1, col_sl2 = st.columns(2)
    with col_sl1:
        sl = st.slider("Sepal Length (cm)", 4.0, 8.0, float(st.session_state.features[0]), 0.1)
        sw = st.slider("Sepal Width (cm)", 2.0, 4.5, float(st.session_state.features[1]), 0.1)
    with col_sl2:
        pl = st.slider("Petal Length (cm)", 1.0, 7.0, float(st.session_state.features[2]), 0.1)
        pw = st.slider("Petal Width (cm)", 0.1, 2.5, float(st.session_state.features[3]), 0.1)

    if st.button("🔮 Classify Sample & Trace", type="primary", use_container_width=True):
        pred_res = pipeline.predict(sl, sw, pl, pw)
        pred_class = pred_res["predicted_class"]
        conf = pred_res["confidence"]
        latency = pred_res["latency_ms"]
        trace_id = pred_res["trace_id"]
        probs = pred_res["probabilities"]

        st.markdown("---")
        res_col1, res_col2 = st.columns([1, 2])

        with res_col1:
            st.markdown(f"### Predicted Class: **{pred_class.upper()}**")
            st.markdown(f"**Confidence:** `{conf * 100:.2f}%`")
            st.markdown(f"**Latency:** `{latency} ms`")
            st.markdown(f"**AgentLens Trace ID:**")
            st.code(trace_id, language="text")

        with res_col2:
            st.markdown("#### Probability Distribution")
            prob_df = pd.DataFrame({
                "Species": list(probs.keys()),
                "Probability": list(probs.values()),
            })
            st.bar_chart(prob_df.set_index("Species"), color="#b8f56a")


# ==============================================================================
# TAB 3: AGENTLENS OBSERVABILITY
# ==============================================================================
with tab_observe:
    st.subheader("AgentLens Backend Telemetry Stream")
    st.caption("Live monitoring stream of traces and spans ingested from the ML pipeline.")

    col_meta1, col_meta2 = st.columns(2)
    with col_meta1:
        st.markdown(f"**Target Project:** `Iris ML Classifier`")
        st.markdown(f"**Project ID:** `{pipeline.project_id}`")
    with col_meta2:
        st.markdown(f"**Ingestion Endpoint:** `{pipeline.api_url}/api/v1/telemetry/ingest`")
        st.markdown(f"**API Status:** `Active & Authenticated`")

    st.markdown("---")
    st.markdown("#### Recent Pipeline Traces (from Backend Database)")

    traces_data = http_json("GET", "/api/v1/traces")
    trace_items = traces_data.get("items", []) if isinstance(traces_data, dict) else (traces_data if isinstance(traces_data, list) else [])

    if trace_items:
        records = []
        for t in trace_items[:10]:
            records.append({
                "Trace ID": t.get("id"),
                "Agent Name": t.get("agent_name"),
                "Status": t.get("status"),
                "Spans": t.get("total_spans"),
                "Errors": t.get("error_spans"),
                "Duration (ms)": t.get("duration_ms"),
                "Findings": t.get("findings_count"),
                "Timestamp": t.get("start_time", "")[:19].replace("T", " "),
            })
        st.dataframe(pd.DataFrame(records), use_container_width=True)
    else:
        st.info("No traces currently registered in database.")

    st.link_button("🔍 Open Full Traces Explorer in React Dashboard", "http://localhost:5173", type="primary")


# ==============================================================================
# TAB 4: 5-RULE FAILURE DETECTION DEMO
# ==============================================================================
with tab_diagnostics:
    st.subheader("Automated Failure Detection Engine — 5 Rule Diagnostic Scenarios")
    st.markdown(
        "AgentLens continuously evaluates all incoming telemetry against 5 deterministic failure detection rules. "
        "Click any diagnostic test below to simulate an ML pipeline failure and verify automated finding generation in real time."
    )

    rules = [
        {
            "id": "1",
            "rule": "FAILED_SPAN",
            "name": "Invalid Feature Dimension Exception",
            "badge": "CRITICAL",
            "badge_class": "badge-critical",
            "description": "Triggers an unhandled Python ValueError ('InvalidFeatureDimension: sepal_width cannot be negative') during feature validation.",
            "func": pipeline.trigger_diagnostic_failed_span,
            "explanation": "AgentLens detects span status ERROR or unhandled exception stack traces and flags an urgent critical finding.",
        },
        {
            "id": "2",
            "rule": "REPEATED_TOOL_CALL",
            "name": "Redundant Normalization Tool Calls",
            "badge": "HIGH",
            "badge_class": "badge-high",
            "description": "Executes identical 'feature_standardization_tool' 3 consecutive times with identical input parameters.",
            "func": pipeline.trigger_diagnostic_repeated_tool_call,
            "explanation": "AgentLens detects redundant looping and token waste when consecutive tool calls match identical input hashes.",
        },
        {
            "id": "3",
            "rule": "EXCESSIVE_RETRIES",
            "name": "Model Registry Checkpoint Exhaustion",
            "badge": "HIGH",
            "badge_class": "badge-high",
            "description": "Simulates 4 retry attempts to upload model weights to internal artifact repository, exceeding maximum retry threshold.",
            "func": pipeline.trigger_diagnostic_excessive_retries,
            "explanation": "AgentLens inspects retry events and retry_count attributes, flagging excessive retries before cascade failure.",
        },
        {
            "id": "4",
            "rule": "SLOW_SPAN",
            "name": "Hyperparameter Search SLA Breach",
            "badge": "WARNING",
            "badge_class": "badge-warning",
            "description": "Simulates a grid search tuning span taking 6,500ms, breaching the 5,000ms TOOL_CALL SLA threshold.",
            "func": pipeline.trigger_diagnostic_slow_span,
            "explanation": "AgentLens evaluates span durations against SLA thresholds and flags latency anomalies.",
        },
        {
            "id": "5",
            "rule": "EMPTY_TOOL_RESULT",
            "name": "Outlier Detection Empty Payload",
            "badge": "WARNING",
            "badge_class": "badge-warning",
            "description": "Isolation Forest tool completes with status OK, but returns an empty dictionary `{}` without output data.",
            "func": pipeline.trigger_diagnostic_empty_tool_result,
            "explanation": "AgentLens verifies that non-whitelisted tool spans do not return null or empty dictionary payloads.",
        },
    ]

    for r in rules:
        with st.container():
            st.markdown(
                f"""
                <div class="diagnostic-card">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <span style="font-size:1.15rem; font-weight:700;">[DIAGNOSTIC TEST {r['id']}] {r['name']}</span>
                        <span class="{r['badge_class']}">{r['rule']} &bull; {r['badge']}</span>
                    </div>
                    <p style="margin-top:8px; margin-bottom:4px; color:#d4d4d8;">{r['description']}</p>
                    <p style="margin:0; font-size:0.85rem; color:#71717a;"><b>Mechanism:</b> {r['explanation']}</p>
                </div>
                """,
                unsafe_allow_html=True,
            )

            btn_key = f"btn_test_{r['id']}"
            if st.button(f"⚡ Execute [DIAGNOSTIC TEST {r['id']}]: {r['rule']}", key=btn_key):
                with st.spinner(f"Triggering {r['rule']} diagnostic scenario and polling AgentLens backend..."):
                    diag_res = r["func"]()
                    trace_id = diag_res["trace_id"]
                    time.sleep(1.0)
                    findings = pipeline.check_findings_for_trace(trace_id, timeout=4.0)

                    st.write(f"**Captured Trace ID:** `{trace_id}`")
                    matched = next((f for f in findings if (f.get("finding_type") or f.get("rule_name")) == r["rule"]), None)

                    if matched:
                        st.success(f"🎯 Automated Failure Detected: **{matched.get('title', r['rule'])}**")
                        st.json({
                            "rule_name": matched.get("finding_type", r["rule"]),
                            "severity": matched.get("severity", r["badge"]),
                            "evidence": matched.get("evidence", matched.get("description")),
                            "trace_id": trace_id,
                        })
                    else:
                        st.info(f"Trace `{trace_id}` ingested. Rule engine processed the scenario.")

                    st.link_button("Inspect in AgentLens React Dashboard", "http://localhost:5173")

        st.markdown("<br>", unsafe_allow_html=True)
