import React, { useEffect, useState } from 'react';
import {
  BrainCircuit,
  Play,
  RotateCw,
  Sliders,
  AlertTriangle,
  Repeat,
  RotateCcw,
  Clock,
  Code2,
  CheckCircle2,
  ArrowRight,
  GitFork,
  ShieldAlert,
  Activity,
  Cpu
} from 'lucide-react';
import { useApp } from '../../context/useApp';
import {
  fetchMlModelInfo,
  trainMlModel,
  predictMlSample,
  runMlDiagnostic,
  type MlModelInfoResponse,
  type MlPredictResponse,
  type MlDiagnosticResponse
} from '../../services/api';

const PRESET_SAMPLES = [
  { name: '🌱 Setosa Preset', values: [5.1, 3.5, 1.4, 0.2], expected: 'setosa' },
  { name: '🌿 Versicolor Preset', values: [6.0, 2.9, 4.5, 1.5], expected: 'versicolor' },
  { name: '🌸 Virginica Preset', values: [6.8, 3.2, 5.9, 2.3], expected: 'virginica' },
];

interface DiagnosticCardConfig {
  id: string;
  ruleType: string;
  name: string;
  severity: 'CRITICAL' | 'HIGH' | 'WARNING';
  icon: React.ElementType;
  description: string;
  mechanism: string;
}

const DIAGNOSTIC_CARDS: DiagnosticCardConfig[] = [
  {
    id: '1',
    ruleType: 'FAILED_SPAN',
    name: 'Invalid Feature Dimension Exception',
    severity: 'CRITICAL',
    icon: AlertTriangle,
    description: 'Simulates negative sepal width (-2.4cm) triggering an unhandled Python ValueError.',
    mechanism: "Flags span status == 'ERROR' and captures the unhandled exception stack trace.",
  },
  {
    id: '2',
    ruleType: 'REPEATED_TOOL_CALL',
    name: 'Redundant Normalization Tool Calls',
    severity: 'HIGH',
    icon: Repeat,
    description: 'Executes identical feature standardization tool 3 consecutive times with matching input hashes.',
    mechanism: 'Detects redundant tool execution loops and token waste across consecutive steps.',
  },
  {
    id: '3',
    ruleType: 'EXCESSIVE_RETRIES',
    name: 'Model Registry Checkpoint Exhaustion',
    severity: 'HIGH',
    icon: RotateCcw,
    description: 'Simulates model artifact upload failing repeatedly through 4 retry attempts.',
    mechanism: 'Detects retry_attempt events and attributes exceeding max allowed retry threshold (>3).',
  },
  {
    id: '4',
    ruleType: 'SLOW_SPAN',
    name: 'Hyperparameter Search SLA Breach',
    severity: 'WARNING',
    icon: Clock,
    description: 'Simulates grid search CV taking 6,500ms, breaching the 5,000ms TOOL_CALL SLA budget.',
    mechanism: 'Evaluates span duration against configured SLA threshold (SLA = 5,000ms).',
  },
  {
    id: '5',
    ruleType: 'EMPTY_TOOL_RESULT',
    name: 'Outlier Detection Empty Payload',
    severity: 'WARNING',
    icon: Code2,
    description: 'Outlier detection tool finishes with status OK but returns an empty dictionary payload {}.',
    mechanism: 'Detects non-whitelisted tools exiting OK without returning output data to agent.',
  },
];

export const MLPlaygroundView: React.FC = () => {
  const { setActiveTab } = useApp();

  // Model training state
  const [modelInfo, setModelInfo] = useState<MlModelInfoResponse | null>(null);
  const [isTraining, setIsTraining] = useState(false);
  const [nEstimators, setNEstimators] = useState(100);

  // Live inference state
  const [features, setFeatures] = useState<[number, number, number, number]>([5.1, 3.5, 1.4, 0.2]);
  const [isPredicting, setIsPredicting] = useState(false);
  const [prediction, setPrediction] = useState<MlPredictResponse | null>(null);

  // Latest execution observability state
  const [latestTraceId, setLatestTraceId] = useState<string>('');
  const [latestTraceType, setLatestTraceType] = useState<string>('training');

  // Diagnostic tests state
  const [diagnosticResults, setDiagnosticResults] = useState<Record<string, MlDiagnosticResponse>>({});
  const [runningDiagnostic, setRunningDiagnostic] = useState<string | null>(null);

  // Initial load
  useEffect(() => {
    let isMounted = true;
    async function loadInitial() {
      try {
        const info = await fetchMlModelInfo();
        if (isMounted) {
          setModelInfo(info);
          if (info.trace_id) {
            setLatestTraceId(info.trace_id);
            setLatestTraceType('training');
          }
        }
      } catch {
        // Fall back gracefully
      }
    }
    loadInitial();
    return () => {
      isMounted = false;
    };
  }, []);

  // Train model handler
  const handleTrain = async () => {
    setIsTraining(true);
    try {
      const res = await trainMlModel({ n_estimators: nEstimators, random_state: 42 });
      setModelInfo(res);
      setLatestTraceId(res.trace_id);
      setLatestTraceType('Model Training & Evaluation (5 Spans)');
    } catch (err) {
      console.error('Failed to train model:', err);
    } finally {
      setIsTraining(false);
    }
  };

  // Predict handler
  const handlePredict = async () => {
    setIsPredicting(true);
    try {
      const res = await predictMlSample({
        sepal_length: features[0],
        sepal_width: features[1],
        petal_length: features[2],
        petal_width: features[3],
      });
      setPrediction(res);
      setLatestTraceId(res.trace_id);
      setLatestTraceType(`Inference (${res.predicted_class.toUpperCase()})`);
    } catch (err) {
      console.error('Inference failed:', err);
    } finally {
      setIsPredicting(false);
    }
  };

  // Diagnostic runner
  const handleRunDiagnostic = async (ruleType: string) => {
    setRunningDiagnostic(ruleType);
    try {
      const res = await runMlDiagnostic(ruleType);
      setDiagnosticResults((prev) => ({ ...prev, [ruleType]: res }));
      setLatestTraceId(res.trace_id);
      setLatestTraceType(`[DIAGNOSTIC TEST] ${ruleType}`);
    } catch (err) {
      console.error(`Diagnostic ${ruleType} failed:`, err);
    } finally {
      setRunningDiagnostic(null);
    }
  };

  const metrics = modelInfo?.metrics;
  const confusionMatrix = modelInfo?.confusion_matrix || [[10, 0, 0], [0, 9, 1], [0, 2, 8]];
  const featureImportances = modelInfo?.feature_importances || [
    { feature: 'petal length', importance: 0.44 },
    { feature: 'petal width', importance: 0.42 },
    { feature: 'sepal length', importance: 0.11 },
    { feature: 'sepal width', importance: 0.03 },
  ];
  const targetClasses = modelInfo?.target_names || ['setosa', 'versicolor', 'virginica'];

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Page Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-[#252d28]">
        <div>
          <div className="flex items-center gap-2.5">
            <div className="p-1.5 rounded-md bg-[#171c19] text-[#b8f56a] border border-[#252d28]">
              <BrainCircuit className="h-5 w-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-lg font-bold text-[#f5f7f5] font-mono tracking-tight">
                  Machine Learning Observability Playground
                </h1>
                <span className="px-2 py-0.5 text-[9px] font-mono font-bold uppercase tracking-wider rounded-xs bg-[#b8f56a]/10 text-[#b8f56a] border border-[#b8f56a]/30">
                  Live Scikit-learn
                </span>
              </div>
              <p className="text-xs text-[#88948a] font-sans mt-0.5">
                Real-time training, inference tracing, and automated 5-rule failure detection powered by AgentLens SDK.
              </p>
            </div>
          </div>
        </div>

        <div className="flex items-center gap-2 text-xs font-mono">
          <button
            onClick={() => setActiveTab('traces')}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-[#111412] hover:bg-[#171c19] text-[#b8f56a] border border-[#252d28] transition-colors"
          >
            <GitFork className="h-3.5 w-3.5" />
            <span>Trace Explorer</span>
          </button>
          <button
            onClick={() => setActiveTab('failures')}
            className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-[#111412] hover:bg-[#171c19] text-[#f06f68] border border-[#252d28] transition-colors"
          >
            <ShieldAlert className="h-3.5 w-3.5" />
            <span>Failure Findings</span>
          </button>
        </div>
      </div>

      {/* Dataset & Architecture Info Pill */}
      <div className="p-3 bg-[#0c0e0d] border border-[#252d28] rounded-md flex flex-wrap items-center justify-between gap-3 text-xs font-mono">
        <div className="flex flex-wrap items-center gap-4 text-[#88948a]">
          <span className="text-[#f5f7f5] font-semibold">Fisher's Iris Dataset</span>
          <span>&bull;</span>
          <span>150 Total Samples</span>
          <span>&bull;</span>
          <span>4 Morphological Features</span>
          <span>&bull;</span>
          <span>3 Botanical Classes</span>
          <span>&bull;</span>
          <span>80% Train (120) / 20% Test (30) Stratified Split</span>
        </div>
        <div className="flex items-center gap-2">
          <span className="h-2 w-2 rounded-full bg-[#b8f56a] animate-pulse" />
          <span className="text-[#b8f56a] font-semibold">SDK Instrumentation Active</span>
        </div>
      </div>

      {/* =========================================================================
          SECTION A: MODEL TRAINING & EVALUATION
         ========================================================================= */}
      <div className="p-5 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
          <div className="flex items-center gap-2">
            <Cpu className="h-4 w-4 text-[#b8f56a]" />
            <h2 className="text-sm font-bold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Section A: Model Training & Evaluation
            </h2>
          </div>

          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 text-xs font-mono text-[#88948a]">
              <span>Estimators:</span>
              <input
                type="range"
                min="10"
                max="250"
                step="10"
                value={nEstimators}
                onChange={(e) => setNEstimators(Number(e.target.value))}
                className="w-24 accent-[#b8f56a]"
              />
              <span className="text-[#b8f56a] font-bold w-7 text-right">{nEstimators}</span>
            </div>

            <button
              onClick={handleTrain}
              disabled={isTraining}
              className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-md bg-[#b8f56a] hover:bg-[#a6e656] text-[#080908] font-mono font-bold text-xs transition-colors disabled:opacity-50"
            >
              <RotateCw className={`h-3.5 w-3.5 ${isTraining ? 'animate-spin' : ''}`} />
              <span>{isTraining ? 'Training Model...' : 'Train Model & Emit Spans'}</span>
            </button>
          </div>
        </div>

        {/* Evaluation Metrics Cards */}
        <div className="grid grid-cols-2 sm:grid-cols-5 gap-3">
          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono text-[#88948a] uppercase tracking-wider block">Accuracy</span>
            <div className="text-2xl font-bold font-mono text-[#b8f56a]">
              {metrics ? `${(metrics.accuracy * 100).toFixed(1)}%` : '90.0%'}
            </div>
            <span className="text-[10px] font-mono text-[#88948a]">Test split: 30 samples</span>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono text-[#88948a] uppercase tracking-wider block">Precision</span>
            <div className="text-2xl font-bold font-mono text-[#6bc8c1]">
              {metrics ? `${(metrics.precision * 100).toFixed(1)}%` : '90.2%'}
            </div>
            <span className="text-[10px] font-mono text-[#88948a]">Weighted average</span>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono text-[#88948a] uppercase tracking-wider block">Recall</span>
            <div className="text-2xl font-bold font-mono text-[#e5ad55]">
              {metrics ? `${(metrics.recall * 100).toFixed(1)}%` : '90.0%'}
            </div>
            <span className="text-[10px] font-mono text-[#88948a]">Weighted average</span>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono text-[#88948a] uppercase tracking-wider block">F1-Score</span>
            <div className="text-2xl font-bold font-mono text-[#a78bfa]">
              {metrics ? `${(metrics.f1_score * 100).toFixed(1)}%` : '90.0%'}
            </div>
            <span className="text-[10px] font-mono text-[#88948a]">Harmonic mean</span>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono text-[#88948a] uppercase tracking-wider block">Pipeline Latency</span>
            <div className="text-2xl font-bold font-mono text-[#f5f7f5]">
              {metrics ? `${metrics.duration_ms} ms` : '38 ms'}
            </div>
            <span className="text-[10px] font-mono text-[#88948a]">5 spans captured</span>
          </div>
        </div>

        {/* Visual Charts: Confusion Matrix & Feature Importances */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5 pt-2">
          {/* Confusion Matrix Table */}
          <div className="p-4 rounded-md bg-[#111412] border border-[#252d28] space-y-3">
            <div className="flex items-center justify-between border-b border-[#252d28] pb-2">
              <span className="text-xs font-mono font-bold text-[#f5f7f5] uppercase tracking-wider">
                Confusion Matrix (3x3 Multiclass)
              </span>
              <span className="text-[10px] font-mono text-[#88948a]">Actual \ Predicted</span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-xs font-mono text-center border-collapse">
                <thead>
                  <tr className="border-b border-[#252d28] text-[#88948a]">
                    <th className="p-2 text-left font-medium">Actual Class</th>
                    <th className="p-2 font-medium">Pred: Setosa</th>
                    <th className="p-2 font-medium">Pred: Versicolor</th>
                    <th className="p-2 font-medium">Pred: Virginica</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#252d28]">
                  {confusionMatrix.map((row, rIdx) => (
                    <tr key={rIdx} className="hover:bg-[#171c19] transition-colors">
                      <td className="p-2 text-left font-bold text-[#f5f7f5]">{targetClasses[rIdx] || `Class ${rIdx}`}</td>
                      {row.map((count, cIdx) => {
                        const isDiagonal = rIdx === cIdx;
                        return (
                          <td
                            key={cIdx}
                            className={`p-2 font-bold ${
                              isDiagonal
                                ? 'bg-[#b8f56a]/15 text-[#b8f56a] border border-[#b8f56a]/30 rounded-xs'
                                : count > 0
                                ? 'bg-[#f06f68]/15 text-[#f06f68] border border-[#f06f68]/30 rounded-xs'
                                : 'text-[#626b64]'
                            }`}
                          >
                            {count}
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <p className="text-[10px] font-mono text-[#88948a]">
              Green diagonal cells represent correct classifications. Off-diagonal numbers show prediction errors.
            </p>
          </div>

          {/* Feature Importances Bar Chart */}
          <div className="p-4 rounded-md bg-[#111412] border border-[#252d28] space-y-3">
            <div className="flex items-center justify-between border-b border-[#252d28] pb-2">
              <span className="text-xs font-mono font-bold text-[#f5f7f5] uppercase tracking-wider">
                Feature Importances (Random Forest Gini)
              </span>
              <span className="text-[10px] font-mono text-[#88948a]">Normalized %</span>
            </div>

            <div className="space-y-3 pt-1">
              {featureImportances.map((item) => (
                <div key={item.feature} className="space-y-1">
                  <div className="flex items-center justify-between text-xs font-mono">
                    <span className="text-[#f5f7f5] capitalize">{item.feature}</span>
                    <span className="text-[#b8f56a] font-bold">{(item.importance * 100).toFixed(1)}%</span>
                  </div>
                  <div className="w-full h-2 rounded-xs bg-[#171c19] overflow-hidden">
                    <div
                      className="h-full bg-[#b8f56a] transition-all duration-300"
                      style={{ width: `${Math.min(100, item.importance * 100)}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
            <p className="text-[10px] font-mono text-[#88948a]">
              Calculated directly by Scikit-learn during tree partitioning; petal measurements dominate classification power.
            </p>
          </div>
        </div>
      </div>

      {/* =========================================================================
          SECTION B: LIVE PREDICTION (SINGLE SAMPLE INFERENCE)
         ========================================================================= */}
      <div className="p-5 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
          <div className="flex items-center gap-2">
            <Sliders className="h-4 w-4 text-[#b8f56a]" />
            <h2 className="text-sm font-bold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Section B: Live Model Inference & Prediction
            </h2>
          </div>

          <div className="flex items-center gap-2">
            {PRESET_SAMPLES.map((preset, idx) => (
              <button
                key={idx}
                onClick={() => setFeatures(preset.values as [number, number, number, number])}
                className="px-2.5 py-1 rounded-md bg-[#111412] hover:bg-[#171c19] text-[#f5f7f5] border border-[#252d28] text-xs font-mono transition-colors"
              >
                {preset.name}
              </button>
            ))}
          </div>
        </div>

        {/* Input Sliders Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-2">
            <div className="flex items-center justify-between text-xs font-mono">
              <span className="text-[#88948a]">Sepal Length:</span>
              <span className="text-[#b8f56a] font-bold">{features[0].toFixed(1)} cm</span>
            </div>
            <input
              type="range"
              min="4.0"
              max="8.0"
              step="0.1"
              value={features[0]}
              onChange={(e) => setFeatures([Number(e.target.value), features[1], features[2], features[3]])}
              className="w-full accent-[#b8f56a]"
            />
            <div className="flex justify-between text-[10px] font-mono text-[#626b64]">
              <span>4.0cm</span>
              <span>8.0cm</span>
            </div>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-2">
            <div className="flex items-center justify-between text-xs font-mono">
              <span className="text-[#88948a]">Sepal Width:</span>
              <span className="text-[#b8f56a] font-bold">{features[1].toFixed(1)} cm</span>
            </div>
            <input
              type="range"
              min="2.0"
              max="4.5"
              step="0.1"
              value={features[1]}
              onChange={(e) => setFeatures([features[0], Number(e.target.value), features[2], features[3]])}
              className="w-full accent-[#b8f56a]"
            />
            <div className="flex justify-between text-[10px] font-mono text-[#626b64]">
              <span>2.0cm</span>
              <span>4.5cm</span>
            </div>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-2">
            <div className="flex items-center justify-between text-xs font-mono">
              <span className="text-[#88948a]">Petal Length:</span>
              <span className="text-[#b8f56a] font-bold">{features[2].toFixed(1)} cm</span>
            </div>
            <input
              type="range"
              min="1.0"
              max="7.0"
              step="0.1"
              value={features[2]}
              onChange={(e) => setFeatures([features[0], features[1], Number(e.target.value), features[3]])}
              className="w-full accent-[#b8f56a]"
            />
            <div className="flex justify-between text-[10px] font-mono text-[#626b64]">
              <span>1.0cm</span>
              <span>7.0cm</span>
            </div>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-2">
            <div className="flex items-center justify-between text-xs font-mono">
              <span className="text-[#88948a]">Petal Width:</span>
              <span className="text-[#b8f56a] font-bold">{features[3].toFixed(1)} cm</span>
            </div>
            <input
              type="range"
              min="0.1"
              max="2.5"
              step="0.1"
              value={features[3]}
              onChange={(e) => setFeatures([features[0], features[1], features[2], Number(e.target.value)])}
              className="w-full accent-[#b8f56a]"
            />
            <div className="flex justify-between text-[10px] font-mono text-[#626b64]">
              <span>0.1cm</span>
              <span>2.5cm</span>
            </div>
          </div>
        </div>

        <button
          onClick={handlePredict}
          disabled={isPredicting}
          className="w-full py-2.5 rounded-md bg-[#b8f56a] hover:bg-[#a6e656] text-[#080908] font-mono font-bold text-xs flex items-center justify-center gap-2 transition-colors disabled:opacity-50"
        >
          <Play className={`h-4 w-4 ${isPredicting ? 'animate-spin' : ''}`} />
          <span>{isPredicting ? 'Computing Inference & Ingesting Trace...' : 'Classify Unseen Sample & Emit Trace'}</span>
        </button>

        {/* Prediction Results Box */}
        {prediction && (
          <div className="p-4 rounded-md bg-[#111412] border border-[#252d28] grid grid-cols-1 lg:grid-cols-12 gap-5 items-center">
            <div className="lg:col-span-5 space-y-1.5 border-b lg:border-b-0 lg:border-r border-[#252d28] pb-3 lg:pb-0 lg:pr-4">
              <span className="text-[10px] font-mono uppercase tracking-wider text-[#88948a]">
                Predicted Botanical Classification
              </span>
              <div className="flex items-center gap-3">
                <span className="px-3 py-1 rounded-md text-base font-bold font-mono uppercase bg-[#b8f56a]/15 text-[#b8f56a] border border-[#b8f56a]/30">
                  Iris {prediction.predicted_class}
                </span>
                <span className="text-xs font-mono text-[#f5f7f5] font-semibold">
                  {(prediction.confidence * 100).toFixed(1)}% Confidence
                </span>
              </div>
              <div className="text-[11px] font-mono text-[#88948a] flex items-center gap-3 pt-1">
                <span>Latency: {prediction.latency_ms} ms</span>
                <span>&bull;</span>
                <span className="text-[#6bc8c1]">Trace: {prediction.trace_id}</span>
              </div>
            </div>

            {/* Probability Bars */}
            <div className="lg:col-span-7 space-y-2">
              <span className="text-[10px] font-mono uppercase tracking-wider text-[#88948a] block">
                Class Probability Distribution
              </span>
              {Object.entries(prediction.probabilities).map(([className, prob]) => (
                <div key={className} className="space-y-1">
                  <div className="flex justify-between text-xs font-mono">
                    <span className="text-[#f5f7f5] capitalize">Iris {className}</span>
                    <span className="text-[#b8f56a] font-bold">{(prob * 100).toFixed(1)}%</span>
                  </div>
                  <div className="w-full h-2 rounded-xs bg-[#171c19] overflow-hidden">
                    <div
                      className="h-full bg-[#b8f56a] transition-all duration-300"
                      style={{ width: `${Math.min(100, prob * 100)}%` }}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* =========================================================================
          SECTION C: EXECUTION OBSERVABILITY
         ========================================================================= */}
      <div className="p-5 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
          <div className="flex items-center gap-2">
            <Activity className="h-4 w-4 text-[#b8f56a]" />
            <h2 className="text-sm font-bold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Section C: Live Telemetry & Trace Inspection
            </h2>
          </div>

          {latestTraceId && (
            <button
              onClick={() => setActiveTab('traces')}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-[#b8f56a] hover:bg-[#a6e656] text-[#080908] font-mono font-bold text-xs transition-colors"
            >
              <span>View Full Trace ({latestTraceId.slice(0, 12)}...)</span>
              <ArrowRight className="h-3.5 w-3.5" />
            </button>
          )}
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono uppercase tracking-wider text-[#88948a]">Active Trace ID</span>
            <div className="text-sm font-mono font-bold text-[#b8f56a] truncate">
              {latestTraceId || 'Awaiting ML Execution'}
            </div>
            <span className="text-[10px] font-mono text-[#626b64]">Immutable PostgreSQL record</span>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono uppercase tracking-wider text-[#88948a]">Execution Context</span>
            <div className="text-sm font-mono font-bold text-[#f5f7f5] truncate">
              {latestTraceType}
            </div>
            <span className="text-[10px] font-mono text-[#626b64]">Environment: development</span>
          </div>

          <div className="p-3.5 rounded-md bg-[#111412] border border-[#252d28] space-y-1">
            <span className="text-[10px] font-mono uppercase tracking-wider text-[#88948a]">FastAPI Ingestion</span>
            <div className="text-sm font-mono font-bold text-[#67c98a] flex items-center gap-1.5">
              <CheckCircle2 className="h-4 w-4" />
              <span>Ingested & Processed</span>
            </div>
            <span className="text-[10px] font-mono text-[#626b64]">Evaluated by 5-rule engine</span>
          </div>
        </div>
      </div>

      {/* =========================================================================
          SECTION D: 5-RULE FAILURE DETECTION PLAYGROUND
         ========================================================================= */}
      <div className="p-5 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#252d28]">
          <div className="flex items-center gap-2">
            <ShieldAlert className="h-4 w-4 text-[#f06f68]" />
            <h2 className="text-sm font-bold text-[#f5f7f5] font-mono uppercase tracking-wider">
              Section D: Five-Rule Failure Detection Playground
            </h2>
          </div>

          <div className="text-xs font-mono text-[#88948a]">
            Click any test to simulate an ML pipeline failure and verify automated finding detection.
          </div>
        </div>

        <div className="grid grid-cols-1 gap-4">
          {DIAGNOSTIC_CARDS.map((card) => {
            const Icon = card.icon;
            const isRunning = runningDiagnostic === card.ruleType;
            const res = diagnosticResults[card.ruleType];

            const severityBadgeColor =
              card.severity === 'CRITICAL'
                ? 'bg-[#f06f68]/15 text-[#f06f68] border-[#f06f68]/30'
                : card.severity === 'HIGH'
                ? 'bg-[#e5ad55]/15 text-[#e5ad55] border-[#e5ad55]/30'
                : 'bg-[#e5ad55]/10 text-[#e5ad55] border-[#e5ad55]/20';

            return (
              <div
                key={card.id}
                className="p-4 rounded-md bg-[#111412] border border-[#252d28] space-y-3 hover:border-[#354039] transition-colors"
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                  <div className="flex items-center gap-2.5">
                    <div className="p-1.5 rounded-md bg-[#171c19] text-[#b8f56a] border border-[#252d28]">
                      <Icon className="h-4 w-4" />
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-[10px] font-mono font-bold text-[#88948a]">
                          [DIAGNOSTIC TEST {card.id}/5]
                        </span>
                        <h3 className="text-sm font-bold text-[#f5f7f5] font-mono">{card.name}</h3>
                      </div>
                      <span className="text-[11px] font-sans text-[#88948a]">{card.description}</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <span className={`px-2 py-0.5 text-[10px] font-mono font-bold uppercase rounded-xs border ${severityBadgeColor}`}>
                      {card.ruleType} &bull; {card.severity}
                    </span>

                    <button
                      onClick={() => handleRunDiagnostic(card.ruleType)}
                      disabled={isRunning}
                      className="px-3 py-1.5 rounded-md bg-[#171c19] hover:bg-[#202722] text-[#f5f7f5] border border-[#252d28] text-xs font-mono font-bold transition-colors disabled:opacity-50 flex items-center gap-1.5"
                    >
                      <Play className={`h-3 w-3 ${isRunning ? 'animate-spin' : ''}`} />
                      <span>{isRunning ? 'Running Test...' : 'Run Test'}</span>
                    </button>
                  </div>
                </div>

                <div className="text-[10px] font-mono text-[#626b64] bg-[#0c0e0d] px-3 py-1.5 rounded-xs border border-[#1f2521]">
                  <b>Detection Logic:</b> {card.mechanism}
                </div>

                {/* Test Result Display */}
                {res && (
                  <div className="p-3 rounded-md bg-[#0c0e0d] border border-[#252d28] space-y-2">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <span className="h-2 w-2 rounded-full bg-[#b8f56a] animate-pulse" />
                        <span className="text-xs font-mono font-bold text-[#b8f56a]">
                          Finding Generated & Persisted
                        </span>
                      </div>
                      <span className="text-[10px] font-mono text-[#6bc8c1]">Trace ID: {res.trace_id}</span>
                    </div>

                    {res.finding && (
                      <div className="text-xs font-mono space-y-1">
                        <div className="text-[#f5f7f5] font-semibold">{res.finding.summary}</div>
                        {res.finding.evidence_summary && (
                          <div className="text-[#88948a] text-[11px]">{res.finding.evidence_summary}</div>
                        )}
                      </div>
                    )}

                    <div className="flex items-center justify-end gap-2 pt-1 border-t border-[#1f2521]">
                      <button
                        onClick={() => setActiveTab('failures')}
                        className="text-[11px] font-mono text-[#b8f56a] hover:underline flex items-center gap-1"
                      >
                        <span>Inspect in Failure Findings View</span>
                        <ArrowRight className="h-3 w-3" />
                      </button>
                    </div>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default MLPlaygroundView;
