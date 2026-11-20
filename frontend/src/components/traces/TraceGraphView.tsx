import React, { useMemo } from 'react';
import {
  ReactFlow,
  Background,
  Controls,
  MarkerType
} from '@xyflow/react';
import type { Edge, Node } from '@xyflow/react';
import '@xyflow/react/dist/style.css';
import type { Trace, Span } from '../../types';

interface TraceGraphViewProps {
  trace: Trace;
  onSelectSpan: (span: Span) => void;
  selectedSpanId?: string;
}

export const TraceGraphView: React.FC<TraceGraphViewProps> = ({
  trace,
  onSelectSpan,
  selectedSpanId,
}) => {
  // Construct nodes and edges from the span hierarchy
  const { nodes, edges } = useMemo(() => {
    const nodesList: Node[] = [];
    const edgesList: Edge[] = [];

    // Group spans by level (depth from root)
    const spanMap = new Map<string, Span>();
    trace.spans.forEach((s) => spanMap.set(s.id, s));

    const childrenMap = new Map<string, Span[]>();
    trace.spans.forEach((s) => {
      const parentId = s.parentSpanId || 'ROOT';
      const current = childrenMap.get(parentId) || [];
      current.push(s);
      childrenMap.set(parentId, current);
    });

    // Compute simple tree layout coordinates
    const roots = childrenMap.get('ROOT') || [];
    const currentY = 30;

    roots.forEach((rootSpan, rootIdx) => {
      const rootX = 250 + rootIdx * 280;
      nodesList.push({
        id: rootSpan.id,
        data: { label: `${rootSpan.name} (${rootSpan.durationMs}ms)` },
        position: { x: rootX, y: currentY },
        style: {
          background: selectedSpanId === rootSpan.id ? '#1a201c' : '#111512',
          color: rootSpan.status === 'ERROR' ? '#f6928d' : '#f5f7f5',
          border: selectedSpanId === rootSpan.id ? '2px solid #b8f56a' : '1px solid #252d28',
          borderRadius: '6px',
          padding: '8px 12px',
          fontSize: '11px',
          fontFamily: 'monospace',
          fontWeight: 600,
          cursor: 'pointer',
          boxShadow: '0 4px 16px rgba(0, 0, 0, 0.6)',
        },
      });

      // Child spans
      const children = childrenMap.get(rootSpan.id) || [];
      const totalWidth = children.length * 200;
      const startX = rootX - totalWidth / 2 + 100;

      children.forEach((childSpan, childIdx) => {
        const childX = Math.max(50, startX + childIdx * 200);
        const childY = currentY + 120;

        nodesList.push({
          id: childSpan.id,
          data: { label: `${childSpan.name}\n${childSpan.durationMs}ms • ${childSpan.spanType}` },
          position: { x: childX, y: childY },
          style: {
            background: selectedSpanId === childSpan.id ? '#1a201c' : '#111512',
            color: childSpan.status === 'ERROR' ? '#f6928d' : '#f5f7f5',
            border: selectedSpanId === childSpan.id ? '2px solid #b8f56a' : childSpan.status === 'ERROR' ? '1px solid #f06f68' : '1px solid #252d28',
            borderRadius: '6px',
            padding: '8px 12px',
            fontSize: '10px',
            fontFamily: 'monospace',
            whiteSpace: 'pre-line',
            cursor: 'pointer',
            boxShadow: '0 4px 16px rgba(0, 0, 0, 0.6)',
          },
        });

        // Add edge
        edgesList.push({
          id: `edge_${rootSpan.id}_${childSpan.id}`,
          source: rootSpan.id,
          target: childSpan.id,
          animated: childSpan.status === 'RUNNING',
          style: {
            stroke: childSpan.status === 'ERROR' ? '#f06f68' : '#b8f56a',
            strokeWidth: 1.5
          },
          markerEnd: {
            type: MarkerType.ArrowClosed,
            color: childSpan.status === 'ERROR' ? '#f06f68' : '#b8f56a',
          },
        });
      });
    });

    return { nodes: nodesList, edges: edgesList };
  }, [trace, selectedSpanId]);

  return (
    <div className="h-96 w-full rounded-lg bg-[#090b0a] border border-[#252d28] relative overflow-hidden">
      <ReactFlow
        nodes={nodes}
        edges={edges}
        fitView
        onNodeClick={(_, node) => {
          const found = trace.spans.find((s) => s.id === node.id);
          if (found) onSelectSpan(found);
        }}
        proOptions={{ hideAttribution: true }}
      >
        <Background color="#171c19" gap={16} size={1} />
        <Controls
          className="bg-[#111512] border border-[#252d28] rounded text-[#929b94] fill-[#929b94]"
        />
      </ReactFlow>

      {/* Graph Legend */}
      <div className="absolute top-3 left-3 px-2.5 py-1 rounded bg-[#111512]/90 border border-[#252d28] text-[9px] font-mono text-[#929b94] pointer-events-none">
        DAG Execution Flow • Click node to inspect span
      </div>
    </div>
  );
};
