// components/Counter.tsx
"use client";
import React from "react";

type Props = { value: number; onChange: (n: number) => void };

export default function Counter({ value, onChange }: Props) {
  return (
    <div className="qty">
      <button className="btn icon" onClick={() => onChange(Math.max(1, value - 1))}>−</button>
      <span>{value}</span>
      <button className="btn icon" onClick={() => onChange(value + 1)}>＋</button>
    </div>
  );
}
