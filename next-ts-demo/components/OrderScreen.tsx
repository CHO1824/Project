// components/OrderScreen.tsx
"use client";
import React, { useMemo, useState } from "react";
import Counter from "./Counter";

// 타입
type MenuItem = {
  id: string;
  name: string;
  desc?: string;
  price: number;
  img?: string;
  category: string;
  options?: {
    label: string;
    choices: { key: string; label: string; priceDelta?: number }[];
  }[];
};
type CartLine = { id: string; itemId: string; qty: number; selections: Record<string, string> };

// 데모 메뉴
const MENU: MenuItem[] = [
  {
    id: "b01", name: "불고기 버거", desc: "달짝지근한 불고기 패티와 신선한 야채", price: 5900,
    img: "https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=1200&auto=format&fit=crop",
    category: "버거",
    options: [
      { label: "세트", choices: [{ key: "single", label: "단품" }, { key: "set", label: "세트(+2,000)", priceDelta: 2000 }] },
    ],
  },
  {
    id: "d01", name: "아메리카노", desc: "산미 밸런스 원두", price: 3000,
    img: "https://images.unsplash.com/photo-1498804103079-a6351b050096?q=80&w=1200&auto=format&fit=crop",
    category: "음료",
    options: [
      { label: "사이즈", choices: [{ key: "s", label: "S" }, { key: "m", label: "M(+500)", priceDelta: 500 }, { key: "l", label: "L(+1,000)", priceDelta: 1000 }] },
    ],
  },
  {
    id: "s01", name: "감자튀김", desc: "겉바속촉 프렌치 프라이", price: 2500,
    img: "https://images.unsplash.com/photo-1550547660-64c2d95f1f8b?q=80&w=1200&auto=format&fit=crop",
    category: "사이드",
  },
];

const KRW = (v: number) => v.toLocaleString("ko-KR");

function priceWithSelections(item: MenuItem, sel: Record<string, string>) {
  let price = item.price;
  item.options?.forEach((opt) => {
    const key = sel[opt.label] ?? opt.choices[0].key;
    const c = opt.choices.find((x) => x.key === key);
    if (c?.priceDelta) price += c.priceDelta;
  });
  return price;
}

function signatureFor(item: MenuItem, sel: Record<string, string>) {
  const sig = item.options?.map((o) => `${o.label}:${sel[o.label] ?? o.choices[0].key}`).join("|") ?? "-";
  return `${item.id}__${sig}`;
}

export default function OrderScreen() {
  const [query, setQuery] = useState("");
  const [activeCat, setActiveCat] = useState<string>("전체");
  const [cart, setCart] = useState<CartLine[]>([]);

  const categories = useMemo(() => ["전체", ...Array.from(new Set(MENU.map((m) => m.category)))], []);
  const filtered = useMemo(
    () => MENU.filter((m) => (activeCat === "전체" || m.category === activeCat) && (m.name.includes(query) || (m.desc ?? "").includes(query))),
    [activeCat, query]
  );

  const subtotal = useMemo(
    () => cart.reduce((sum, line) => sum + priceWithSelections(MENU.find(m => m.id === line.itemId)!, line.selections) * line.qty, 0),
    [cart]
  );
  const tax = Math.round(subtotal * 0.1);
  const grand = subtotal + tax;

  const addToCart = (item: MenuItem, sel: Record<string, string>, qty: number) => {
    const id = signatureFor(item, sel);
    setCart((prev) => {
      const i = prev.findIndex((l) => l.id === id);
      if (i >= 0) { const next = [...prev]; next[i].qty += qty; return next; }
      return [...prev, { id, itemId: item.id, qty, selections: sel }];
    });
  };
  const setQty = (id: string, qty: number) => setCart((prev) => prev.map((l) => (l.id === id ? { ...l, qty } : l)));
  const removeLine = (id: string) => setCart((prev) => prev.filter((l) => l.id !== id));
  const clear = () => setCart([]);

  return (
    <>
      <header className="sticky">
        <div className="container flex between wrap" style={{ gap: 10, padding: "12px 16px" }}>
          <div className="title" style={{ fontSize: 20 }}>🍔 FastBite (Next.js + TS)</div>
          <div className="search" style={{ width: 260, maxWidth: "100%" }}>
            <span className="icon">🔎</span>
            <input placeholder="메뉴 검색" value={query} onChange={(e) => setQuery(e.target.value)} />
          </div>
          <button className="btn primary">
            🧺 장바구니 <span className="pill" style={{ marginLeft: 6 }}>{cart.reduce((n, l) => n + l.qty, 0)}</span>
          </button>
        </div>
      </header>

      <main className="container">
        <div className="row">
          <section>
            <div className="flex wrap" style={{ gap: 8, margin: "10px 0 16px" }}>
              {categories.map((c) => (
                <button key={c}
                  className={`btn ${c === activeCat ? "primary" : ""}`}
                  onClick={() => setActiveCat(c)}
                >{c}</button>
              ))}
            </div>

            <div className="grid">
              {filtered.map((item) => <MenuCard key={item.id} item={item} onAdd={addToCart} />)}
            </div>
          </section>

          {/* 사이드 장바구니 */}
          <aside className="card" style={{ alignSelf: "start", position: "sticky", top: 76 }}>
            <div className="pad">
              <div className="flex between">
                <div className="title">주문 내역</div>
                <div className="pill">{cart.reduce((n, l) => n + l.qty, 0)} 개</div>
              </div>
              <div className="muted" style={{ fontSize: 14, marginTop: 4 }}>선택한 상품을 확인하세요.</div>
            </div>
            <div className="pad list">
              {cart.length === 0 ? (
                <div className="muted" style={{ textAlign: "center", padding: 24 }}>장바구니가 비어있어요.</div>
              ) : (
                cart.map((line) => {
                  const item = MENU.find((m) => m.id === line.itemId)!;
                  const unit = priceWithSelections(item, line.selections);
                  return (
                    <div key={line.id} style={{ display: "flex", gap: 12, marginBottom: 12, alignItems: "flex-start", justifyContent: "space-between" }}>
                      <div style={{ display: "flex", gap: 10 }}>
                        <img src={item.img} alt={item.name} style={{ width: 64, height: 64, objectFit: "cover", borderRadius: 10, background: "#ddd" }} />
                        <div>
                          <div style={{ fontWeight: 600 }}>{item.name}</div>
                          {item.options?.length ? (
                            <div className="muted" style={{ fontSize: 12 }}>
                              {item.options.map(o => {
                                const key = line.selections[o.label] ?? o.choices[0].key;
                                const choice = o.choices.find(x => x.key === key);
                                return `${o.label}: ${choice?.label}`;
                              }).join(" · ")}
                            </div>
                          ) : null}
                          <div className="muted" style={{ fontSize: 12 }}>개당 {KRW(unit)}원</div>
                        </div>
                      </div>
                      <div className="right">
                        <Counter value={line.qty} onChange={(n) => setQty(line.id, n)} />
                        <div style={{ fontWeight: 700, marginTop: 6 }}>합계 {KRW(unit * line.qty)}원</div>
                        <button className="btn" style={{ marginTop: 6 }} onClick={() => removeLine(line.id)}>삭제</button>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
            <div className="pad">
              <div className="rowline"><span>상품 금액</span><span>{KRW(subtotal)}원</span></div>
              <div className="rowline"><span>부가세(10%)</span><span>{KRW(tax)}원</span></div>
              <div className="divider"></div>
              <div className="rowline" style={{ fontWeight: 700, fontSize: 16 }}><span>결제 금액</span><span>{KRW(grand)}원</span></div>
              <div className="flex" style={{ gap: 12, marginTop: 10 }}>
                <button className="btn" onClick={clear}>비우기</button>
                <button className="btn primary" disabled={!cart.length} onClick={() => alert("결제 완료 (데모)")}>주문하기</button>
              </div>
            </div>
          </aside>
        </div>
      </main>
    </>
  );
}

function MenuCard({ item, onAdd }: { item: MenuItem; onAdd: (item: MenuItem, sel: Record<string, string>, qty: number) => void }) {
  const [qty, setQty] = useState(1);
  const [sel, setSel] = useState<Record<string, string>>({});
  const unit = priceWithSelections(item, sel);

  return (
    <div className="card">
      <img src={item.img} alt={item.name} style={{ width: "100%", height: 150, objectFit: "cover", borderTopLeftRadius: 16, borderTopRightRadius: 16, background: "#ddd" }} />
      <div className="pad">
        <div className="flex between">
          <div>
            <div className="title">{item.name}</div>
            {item.desc && <div className="muted" style={{ fontSize: 14 }}>{item.desc}</div>}
          </div>
          <div className="right" style={{ fontWeight: 700 }}>{KRW(unit)}원</div>
        </div>
      </div>
    </div>
  )}