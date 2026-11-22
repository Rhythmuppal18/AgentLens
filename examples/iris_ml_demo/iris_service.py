import json
import logging
import os
import sys
import time
import urllib.request
import urllib.error
from typing import Any, Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
from sklearn.datasets import load_iris
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score, precision_score, recall_score
from sklearn.model_selection import train_test_split

# Ensure sdk is in Python path
current_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.abspath(os.path.join(current_dir, "..", ".."))
sdk_dir = os.path.join(project_root, "sdk")
if sdk_dir not in sys.path:
    sys.path.insert(0, sdk_dir)

import agentlens

logger = logging.getLogger("agentlens.iris_demo")
API_URL = os.getenv("AGENTLENS_API_URL", "http://localhost:8000")


def http_json(method: str, path: str, data: Optional[dict] = None, headers: Optional[dict] = None) -> dict:
    """Helper to query AgentLens FastAPI endpoints."""
    url = f"{API_URL}{path}"
    req_headers = {"Accept": "application/json"}
    if headers:
        req_headers.update(headers)

    body = None
    if data is not None:
        body = json.dumps(data).encode("utf-8")
        req_headers["Content-Type"] = "application/json"

    req = urllib.request.Request(url, data=body, headers=req_headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as res:
            res_data = res.read().decode("utf-8")
            return json.loads(res_data) if res_data else {}
    except urllib.error.HTTPError as exc:
        err_body = exc.read().decode("utf-8")
        try:
            return json.loads(err_body)
        except Exception:
            return {"error": str(exc), "body": err_body}


class IrisMLPipeline:
    """Production-grade Iris Machine Learning Classifier with native AgentLens observability."""

    def __init__(self, api_url: str = API_URL):
        self.api_url = api_url.rstrip("/")
        self.project_id: Optional[str] = None
        self.api_key: Optional[str] = None
        self.client: Optional[agentlens.AgentLens] = None
        self.model: Optional[RandomForestClassifier] = None
        self.feature_names: List[str] = []
        self.target_names: List[str] = []
        self.latest_metrics: Dict[str, Any] = {}
        self.latest_confusion_matrix: Optional[List[List[int]]] = None

        self._initialize_credentials()

    def _initialize_credentials(self) -> None:
        """Finds or creates the 'Iris ML Classifier' project in AgentLens."""
        try:
            projects = http_json("GET", "/api/v1/projects")
            target_proj = None
            if isinstance(projects, list):
                target_proj = next((p for p in projects if p.get("name") == "Iris ML Classifier"), None)

            if not target_proj:
                target_proj = http_json(
                    "POST",
                    "/api/v1/projects",
                    data={"name": "Iris ML Classifier", "slug": "iris-ml-classifier"},
                )
                self.api_key = target_proj.get("api_key")
                self.project_id = target_proj.get("id")
            else:
                self.project_id = target_proj.get("id")
                # Refresh API key to retrieve plaintext credential
                key_res = http_json("POST", f"/api/v1/projects/{self.project_id}/api-key")
                self.api_key = key_res.get("api_key")

            if self.project_id and self.api_key:
                self.client = agentlens.init(
                    api_key=self.api_key,
                    project_id=self.project_id,
                    environment="development",
                    api_url=self.api_url,
                    capture_payloads=True,
                )
                logger.info("AgentLens SDK initialized for project '%s' (ID: %s)", "Iris ML Classifier", self.project_id)
        except Exception as exc:
            logger.warning("AgentLens backend connection deferred: %s", exc)

        if self.client is None:
            # Fallback client prevents NoneType attribute errors if backend is starting or offline
            self.client = agentlens.init(
                api_key="demo-local-key",
                project_id="00000000-0000-0000-0000-000000000000",
                environment="development",
                api_url=self.api_url,
                disabled=True,
            )

    def train_and_evaluate(self, n_estimators: int = 100, random_state: int = 42) -> Dict[str, Any]:
        """Trains the Random Forest model on genuine Iris data and returns verifiable evaluation metrics."""
        if self.client is None:
            self._initialize_credentials()

        trace_ctx = self.client.trace(
            agent_name="IrisClassifierAgent",
            session_id=f"sess_train_{int(time.time())}",
            metadata={"framework": "scikit-learn", "model": "RandomForestClassifier", "dataset": "iris"},
        ) if self.client else None

        trace_id = trace_ctx.id if trace_ctx else f"local_{int(time.time())}"

        if trace_ctx:
            trace_ctx.__enter__()

        try:
            # 1. Dataset Loading Span
            span_load = self.client.span(
                name="dataset_loading",
                span_type="RETRIEVAL",
                input_payload={"dataset": "iris", "source": "sklearn.datasets"},
            ) if self.client else None

            if span_load:
                span_load.__enter__()
            iris = load_iris()
            X = iris.data
            y = iris.target
            self.feature_names = [name.replace(" (cm)", "") for name in iris.feature_names]
            self.target_names = list(iris.target_names)
            if span_load:
                span_load.set_output({
                    "n_samples": len(X),
                    "n_features": X.shape[1],
                    "feature_names": self.feature_names,
                    "target_names": self.target_names,
                })
                span_load.__exit__(None, None, None)

            # 2. Data Preprocessing Span
            span_prep = self.client.span(
                name="data_preprocessing",
                span_type="AGENT_STEP",
                input_payload={"test_size": 0.2, "random_state": random_state, "stratify": True},
            ) if self.client else None

            if span_prep:
                span_prep.__enter__()
            X_train, X_test, y_train, y_test = train_test_split(
                X, y, test_size=0.2, random_state=random_state, stratify=y
            )
            if span_prep:
                span_prep.set_output({
                    "train_samples": len(X_train),
                    "test_samples": len(X_test),
                    "feature_shape": list(X_train.shape),
                })
                span_prep.__exit__(None, None, None)

            # 3. Model Training Span
            span_train = self.client.span(
                name="model_training",
                span_type="AGENT_STEP",
                input_payload={"model_type": "RandomForestClassifier", "n_estimators": n_estimators, "random_state": random_state},
            ) if self.client else None

            if span_train:
                span_train.__enter__()
            clf = RandomForestClassifier(n_estimators=n_estimators, random_state=random_state)
            clf.fit(X_train, y_train)
            self.model = clf
            if span_train:
                span_train.set_output({
                    "status": "trained",
                    "n_estimators": n_estimators,
                    "feature_importances": {name: round(float(imp), 4) for name, imp in zip(self.feature_names, clf.feature_importances_)},
                })
                span_train.__exit__(None, None, None)

            # 4. Model Evaluation Span
            span_eval = self.client.span(
                name="model_evaluation",
                span_type="AGENT_STEP",
                input_payload={"test_sample_count": len(X_test)},
            ) if self.client else None

            if span_eval:
                span_eval.__enter__()
            y_pred = clf.predict(X_test)
            accuracy = float(accuracy_score(y_test, y_pred))
            precision = float(precision_score(y_test, y_pred, average="weighted", zero_division=0))
            recall = float(recall_score(y_test, y_pred, average="weighted", zero_division=0))
            f1 = float(f1_score(y_test, y_pred, average="weighted", zero_division=0))

            metrics = {
                "accuracy": round(accuracy, 4),
                "precision": round(precision, 4),
                "recall": round(recall, 4),
                "f1_score": round(f1, 4),
                "test_samples": len(X_test),
            }
            self.latest_metrics = metrics
            if span_eval:
                span_eval.set_output(metrics)
                span_eval.__exit__(None, None, None)

            # 5. Confusion Matrix Span
            span_cm = self.client.span(
                name="confusion_matrix_generation",
                span_type="TOOL_CALL",
                input_payload={"labels": self.target_names},
            ) if self.client else None

            if span_cm:
                span_cm.__enter__()
            cm = confusion_matrix(y_test, y_pred).tolist()
            self.latest_confusion_matrix = cm
            if span_cm:
                span_cm.set_output({"confusion_matrix": cm, "classes": self.target_names})
                span_cm.__exit__(None, None, None)

            if trace_ctx:
                trace_ctx.__exit__(None, None, None)
                self.client.flush()

            return {
                "trace_id": trace_id,
                "metrics": metrics,
                "confusion_matrix": cm,
                "feature_names": self.feature_names,
                "target_names": self.target_names,
                "train_samples": len(X_train),
                "test_samples": len(X_test),
            }

        except Exception as exc:
            if trace_ctx:
                trace_ctx.__exit__(type(exc), exc, exc.__traceback__)
                self.client.flush()
            raise

    def predict(self, sepal_length: float, sepal_width: float, petal_length: float, petal_width: float) -> Dict[str, Any]:
        """Executes live flower prediction on unseen user measurements, captured in an AgentLens trace."""
        if self.model is None:
            self.train_and_evaluate()

        if self.client is None:
            self._initialize_credentials()

        input_data = {
            "sepal_length": sepal_length,
            "sepal_width": sepal_width,
            "petal_length": petal_length,
            "petal_width": petal_width,
        }

        trace_ctx = self.client.trace(
            agent_name="IrisInferenceAgent",
            session_id=f"sess_pred_{int(time.time())}",
            metadata={"task": "single_sample_inference"},
        ) if self.client else None

        trace_id = trace_ctx.id if trace_ctx else f"local_{int(time.time())}"

        if trace_ctx:
            trace_ctx.__enter__()

        start_time = time.time()
        try:
            span_pred = self.client.span(
                name="live_prediction",
                span_type="TOOL_CALL",
                input_payload=input_data,
            ) if self.client else None

            if span_pred:
                span_pred.__enter__()

            features = np.array([[sepal_length, sepal_width, petal_length, petal_width]])
            class_idx = int(self.model.predict(features)[0])
            predicted_class = self.target_names[class_idx]

            probabilities = {}
            if hasattr(self.model, "predict_proba"):
                probs = self.model.predict_proba(features)[0]
                for name, p in zip(self.target_names, probs):
                    probabilities[name] = round(float(p), 4)

            confidence = probabilities.get(predicted_class, 1.0)
            latency_ms = int((time.time() - start_time) * 1000)

            output_data = {
                "predicted_class": predicted_class,
                "confidence": confidence,
                "probabilities": probabilities,
                "latency_ms": latency_ms,
            }

            if span_pred:
                span_pred.set_output(output_data)
                span_pred.__exit__(None, None, None)

            if trace_ctx:
                trace_ctx.__exit__(None, None, None)
                self.client.flush()

            return {
                "trace_id": trace_id,
                "predicted_class": predicted_class,
                "confidence": confidence,
                "probabilities": probabilities,
                "latency_ms": latency_ms,
                "input": input_data,
            }

        except Exception as exc:
            if trace_ctx:
                trace_ctx.__exit__(type(exc), exc, exc.__traceback__)
                self.client.flush()
            raise

    # =========================================================================
    # Controlled Diagnostic Scenarios for 5 Failure Rules
    # =========================================================================

    def trigger_diagnostic_failed_span(self) -> Dict[str, Any]:
        """Diagnostic Scenario 1: FAILED_SPAN.
        Triggers a genuine Python exception during feature dimension validation.
        """
        if self.client is None:
            self._initialize_credentials()

        with self.client.trace(
            agent_name="[DIAGNOSTIC TEST] IrisDataValidatorAgent",
            metadata={"diagnostic_scenario": "FAILED_SPAN"},
        ) as trace:
            try:
                with self.client.span(
                    name="validate_feature_bounds",
                    span_type="AGENT_STEP",
                    input_payload={"sepal_width": -2.4, "min_allowed": 0.1},
                ) as span:
                    # Genuine Python ValueError
                    raise ValueError("InvalidFeatureDimension: sepal_width cannot be negative (received -2.4cm)")
            except ValueError:
                # Error caught at higher layer; SDK context manager already captured status=ERROR
                pass

        self.client.flush()
        return {
            "scenario": "FAILED_SPAN",
            "trace_id": trace.id,
            "expected_rule": "FAILED_SPAN",
            "expected_severity": "CRITICAL",
            "description": "Raised genuine ValueError on invalid feature measurement",
        }

    def trigger_diagnostic_repeated_tool_call(self) -> Dict[str, Any]:
        """Diagnostic Scenario 2: REPEATED_TOOL_CALL.
        Executes identical feature scaling tool 3 times consecutively with identical input arguments.
        """
        if self.client is None:
            self._initialize_credentials()

        with self.client.trace(
            agent_name="[DIAGNOSTIC TEST] IrisPreprocessorAgent",
            metadata={"diagnostic_scenario": "REPEATED_TOOL_CALL"},
        ) as trace:
            # 3 consecutive identical tool calls
            for i in range(3):
                with self.client.span(
                    name="feature_standardization_tool",
                    span_type="TOOL_CALL",
                    input_payload={"scaler": "StandardScaler", "columns": ["sepal_length", "sepal_width"]},
                ) as s:
                    s.set_output({"status": "normalized", "mean": [5.84, 3.05], "std": [0.83, 0.43]})

        self.client.flush()
        return {
            "scenario": "REPEATED_TOOL_CALL",
            "trace_id": trace.id,
            "expected_rule": "REPEATED_TOOL_CALL",
            "expected_severity": "HIGH",
            "description": "Executed feature_standardization_tool 3x with identical arguments",
        }

    def trigger_diagnostic_excessive_retries(self) -> Dict[str, Any]:
        """Diagnostic Scenario 3: EXCESSIVE_RETRIES.
        Records an operation exceeding the retry limit (> 3 retries) with retry_attempt events.
        """
        if self.client is None:
            self._initialize_credentials()

        with self.client.trace(
            agent_name="[DIAGNOSTIC TEST] IrisModelRegistryAgent",
            metadata={"diagnostic_scenario": "EXCESSIVE_RETRIES"},
        ) as trace:
            with self.client.span(
                name="sync_model_checkpoint",
                span_type="TOOL_CALL",
                attributes={"retry_count": 4},
                input_payload={"registry_endpoint": "https://models.internal.io/iris_v1", "max_retries": 3},
            ) as s:
                s.event("retry_attempt", {"attempt": 1, "reason": "ConnectionRefused"})
                s.event("retry_attempt", {"attempt": 2, "reason": "ConnectionRefused"})
                s.event("retry_attempt", {"attempt": 3, "reason": "ConnectionRefused"})
                s.event("retry_attempt", {"attempt": 4, "reason": "RetryExhausted"})
                s.status = "ERROR"
                s.error_message = "RetryLimitExceeded: Endpoint unreachable after 4 retries"
                s.error_type = "MaxRetriesExceededError"

        self.client.flush()
        return {
            "scenario": "EXCESSIVE_RETRIES",
            "trace_id": trace.id,
            "expected_rule": "EXCESSIVE_RETRIES",
            "expected_severity": "HIGH",
            "description": "Recorded sync_model_checkpoint failing after 4 retries",
        }

    def trigger_diagnostic_slow_span(self) -> Dict[str, Any]:
        """Diagnostic Scenario 4: SLOW_SPAN.
        Records an operation exceeding the configured SLA threshold (TOOL_CALL SLA is 5000ms; duration is 6500ms).
        """
        if self.client is None:
            self._initialize_credentials()

        with self.client.trace(
            agent_name="[DIAGNOSTIC TEST] IrisHyperparameterTunerAgent",
            metadata={"diagnostic_scenario": "SLOW_SPAN"},
        ) as trace:
            with self.client.span(
                name="grid_search_cv_tuner",
                span_type="TOOL_CALL",
                input_payload={"param_grid": {"n_estimators": [50, 100, 200], "max_depth": [3, 5, 10]}},
            ) as s:
                # Explicitly set duration to 6500ms to simulate a long-running grid search without freezing the demo
                s.set_duration(6500)
                s.set_output({"best_params": {"max_depth": 5, "n_estimators": 100}, "best_score": 0.9667})

        self.client.flush()
        return {
            "scenario": "SLOW_SPAN",
            "trace_id": trace.id,
            "expected_rule": "SLOW_SPAN",
            "expected_severity": "WARNING",
            "description": "grid_search_cv_tuner duration set to 6500ms (exceeds 5000ms TOOL_CALL SLA)",
        }

    def trigger_diagnostic_empty_tool_result(self) -> Dict[str, Any]:
        """Diagnostic Scenario 5: EMPTY_TOOL_RESULT.
        Tool span finishes with status OK but returns an empty dictionary/null output payload.
        """
        if self.client is None:
            self._initialize_credentials()

        with self.client.trace(
            agent_name="[DIAGNOSTIC TEST] IrisOutlierDetectorAgent",
            metadata={"diagnostic_scenario": "EMPTY_TOOL_RESULT"},
        ) as trace:
            with self.client.span(
                name="isolation_forest_outlier_scanner",
                span_type="TOOL_CALL",
                input_payload={"contamination": 0.05, "n_samples": 150},
            ) as s:
                s.status = "OK"
                s.set_output({})  # Empty dictionary triggers EMPTY_TOOL_RESULT

        self.client.flush()
        return {
            "scenario": "EMPTY_TOOL_RESULT",
            "trace_id": trace.id,
            "expected_rule": "EMPTY_TOOL_RESULT",
            "expected_severity": "WARNING",
            "description": "isolation_forest_outlier_scanner returned empty payload {} upon status OK",
        }

    def check_findings_for_trace(self, trace_id: str, timeout: float = 8.0) -> List[Dict[str, Any]]:
        """Polls the backend API for findings associated with a trace."""
        start = time.time()
        while time.time() - start < timeout:
            res = http_json("GET", f"/api/v1/failures?trace_id={trace_id}")
            if isinstance(res, list) and len(res) > 0:
                return res
            elif isinstance(res, dict) and "items" in res and len(res["items"]) > 0:
                return res["items"]
            time.sleep(0.5)
        return []
