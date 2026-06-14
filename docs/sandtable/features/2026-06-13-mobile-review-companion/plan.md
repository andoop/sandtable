# Mobile Review Companion 改动计划

**目标:** 为 Sandtable 增加一个可选的手机审阅协作运行时：本机 server + MCP + 文件信箱 + Android/iOS Flutter App + 常驻轮询协议。

**架构:** 采用 PRD 已确认的方案 A。`docs/sandtable/` 继续作为可恢复事实源；新增 `runtime/server` 作为可选 Node/TypeScript runtime，负责 MCP 工具、文件信箱、局域网配对、WebSocket/SSE 事件和写回 Sandtable 记忆；新增 `apps/mobile` 作为 Flutter App，负责扫码配对、查看文档、回答问题和确认门禁。现有安装/更新方法论资产保持零依赖，runtime 只在开发者显式启用时安装/运行。

**对应 PRD:** prd.md

**对应测试:** tests.md TC1-TC10

**推演要求:** 本计划将由头脑预演、红蓝对抗、实现预演子 agent 逐任务推演。任何实现预演必须在独立 git worktree 中完成。

## 文件地图

- 创建: `docs/mobile-review-companion/protocol.md`
  - 职责: 定义文件信箱、事件类型、确认写回、冲突/幂等规则，作为所有 agent 的最低共同协议。
- 创建: `docs/mobile-review-companion/runtime.md`
  - 职责: 说明 server 启停、局域网配对、MCP 接线、常驻轮询和安全边界。
- 创建: `runtime/server/package.json`
  - 职责: 可选 server runtime 的 Node 包入口、脚本和依赖声明。
- 创建: `runtime/server/tsconfig.json`
  - 职责: TypeScript 编译配置。
- 创建: `runtime/server/src/types.ts`
  - 职责: 共享类型，覆盖 feature、phase、mailbox message、mobile event、pairing session。
- 创建: `runtime/server/src/paths.ts`
  - 职责: 解析 Sandtable repo、feature 目录、runtime mailbox 目录路径。
- 创建: `runtime/server/src/mailbox.ts`
  - 职责: 读写文件信箱、幂等处理消息、把 agent/mobile 消息桥接到 outbox。
- 创建: `runtime/server/src/events.ts`
  - 职责: 维护 server 事件流、WebSocket/SSE 订阅者、outbox 写入和 stop 广播。
- 创建: `runtime/server/src/polling.ts`
  - 职责: 定义低成本/免费等待 worker 队列的游标、ack、lease/heartbeat、stop event、接力规则和通知主 agent 的消息格式。
- 创建: `runtime/server/src/continuation.ts`
  - 职责: 定义 active runtime 下主 agent 不终止的 continuation lease、续租、停止和 polling handoff。
- 创建: `runtime/server/src/sandtable.ts`
  - 职责: 读取 `state.md`、`prd.md`、`tests.md`、`plan.md`、`journal.md`、`questions.md`，并写回 journal/questions/state。
- 创建: `runtime/server/src/mcp.ts`
  - 职责: 暴露 MCP 工具，支持 agent 同步状态、写入消息、读取手机端答复。
- 创建: `runtime/server/src/mcp-stdio.ts`
  - 职责: 提供真实 stdio MCP server 入口，注册 `sandtable_sync_phase`、`sandtable_publish_document`、`sandtable_read_mobile_messages`。
- 创建: `runtime/server/src/http.ts`
  - 职责: 提供局域网 HTTP API、扫码配对接口、WebSocket/SSE 事件通道。
- 创建: `runtime/server/src/index.ts`
  - 职责: server CLI 入口，组合 MCP、HTTP、mailbox watcher 和关闭流程。
- 创建: `runtime/server/test/mailbox.test.ts`
  - 职责: 覆盖 TC3、TC5、TC7、TC10、TC12 的文件信箱读写、outbox 桥接、轮询游标和事实源恢复。
- 创建: `runtime/server/test/continuation.test.ts`
  - 职责: 覆盖 TC11、TC12 的 continuation lease、主 agent handoff、多个等待 worker 接力、stop 结束条件。
- 创建: `runtime/server/test/sandtable.test.ts`
  - 职责: 覆盖 PRD 确认、问题回答写回、安装/更新边界相关行为。
- 创建: `runtime/server/test/http.test.ts`
  - 职责: 覆盖 TC1、TC2、TC4、TC8 的 server API、配对 token 校验、事件流和 stop。
- 创建: `apps/mobile/pubspec.yaml`
  - 职责: Flutter App 包配置和依赖声明。
- 创建: `apps/mobile/lib/main.dart`
  - 职责: Flutter App 入口、主题、路由。
- 创建: `apps/mobile/lib/models.dart`
  - 职责: App 端事件、feature、document、question、confirmation 模型。
- 创建: `apps/mobile/lib/api.dart`
  - 职责: HTTP/WebSocket client、扫码配对 token、提交回答/确认。
- 创建: `apps/mobile/lib/screens/pairing_screen.dart`
  - 职责: 扫描电脑端配对二维码，解析 server URL、feature 和 token。
- 创建: `apps/mobile/lib/screens/feature_screen.dart`
  - 职责: 当前 feature 状态、phase、文档入口和连接状态。
- 创建: `apps/mobile/lib/screens/document_screen.dart`
  - 职责: 展示 PRD/tests/plan/state/journal/questions 文档内容。
- 创建: `apps/mobile/lib/screens/question_screen.dart`
  - 职责: 提交问题回答、PRD/tests/plan 确认和阻塞裁决。
- 创建: `apps/mobile/test/models_test.dart`
  - 职责: App 数据模型序列化测试。
- 创建: `apps/mobile/test/widget_test.dart`
  - 职责: App 基础渲染、未生成文档状态、断开状态测试。
- 修改: `README.md`
  - 职责: 增加 Mobile Review Companion 的可选能力说明和入口链接。
- 修改: `INSTALL.md`
  - 职责: 明确默认安装仍只安装方法论资产；mobile runtime 另按文档显式启用。
- 修改: `UPDATE.md`
  - 职责: 明确更新不触碰 `docs/sandtable/`，也不自动安装/升级 mobile runtime 依赖。
- 修改: `skills/using-sandtable/SKILL.md`
  - 职责: 增加当 mobile runtime 已启用时，agent 在阶段动作后同步 MCP/信箱的纪律；未启用时不改变流程。
- 修改: `plugins/sandtable/skills/using-sandtable/SKILL.md`
  - 职责: 与根 `skills/using-sandtable` 保持 Codex plugin 版本一致。
- 修改: `locales/en/skills/using-sandtable/SKILL.md`
  - 职责: 英文 locale 同步新增纪律。
- 修改: `locales/en/plugins/sandtable/skills/using-sandtable/SKILL.md`
  - 职责: 英文 Codex plugin 版本同步新增纪律。

## 协议基线

首版文件信箱放在项目内 `.sandtable-runtime/mailbox/`，不放入 `docs/sandtable/`，避免污染战役记忆；真正需要持久追溯的开发者回答和确认，由 server 写回 `docs/sandtable/features/<feature>/journal.md`、`questions.md` 或 `state.md`。server 必须把 agent-origin inbox 消息处理成 mobile event 和 outbox message；否则无 MCP agent 的最低可用路径不成立。

消息文件命名:

```text
.sandtable-runtime/mailbox/inbox/<iso8601-compact>-<source>-<nonce>.json
.sandtable-runtime/mailbox/processed/<same-file-name>.json
.sandtable-runtime/mailbox/outbox/<iso8601-compact>-server-<nonce>.json
.sandtable-runtime/mailbox/cursors/<worker-id>.json
.sandtable-runtime/session/continuation.json
```

基础消息结构:

```json
{
  "id": "20260613T175600Z-mobile-0001",
  "feature": "2026-06-13-mobile-review-companion",
  "source": "agent|mobile|server",
  "type": "phase_update|document_snapshot|question_answer|confirmation|stop",
  "createdAt": "2026-06-13T17:56:00+08:00",
  "payload": {}
}
```

server 处理规则:

```text
agent -> inbox -> server processor -> processed + event stream + outbox
mobile -> HTTP/WebSocket -> durable Sandtable write + outbox notification for polling worker
stop -> HTTP /stop or stop mailbox message -> event stream + outbox stop + server shutdown
```

active runtime 下的 agent 流水线生命周期规则:

```text
main agent phase action done
  -> write/renew .sandtable-runtime/session/continuation.json
  -> ensure one or more cheap/free waiting workers are assigned
  -> hand off mailbox waiting to the worker queue
  -> do not terminate the Sandtable session unless stop=true

waiting worker loop
  -> wait by polling, subscription, blocking read, MCP resource watch, or any host-supported cheap operation
  -> read outbox since worker cursor
  -> if no message: update heartbeat/cursor/lease only
  -> if mobile message: notify main agent or relay to the responsible worker, do not edit PRD/tests/plan unless explicitly assigned
  -> if stop: mark continuation stopped and all waiting workers exit
```

`continuation.json` 结构:

```json
{
  "feature": "2026-06-13-mobile-review-companion",
  "phase": "MENTAL_REHEARSAL",
  "active": true,
  "stopped": false,
  "mainAgent": "host-specific-main-agent-id-or-label",
  "waitingWorkers": ["cheap-worker-a", "cheap-worker-b"],
  "workerMode": "poll|subscribe|host-wait|mixed",
  "renewAfter": "2026-06-13T18:33:32+08:00",
  "expiresAt": "2026-06-13T18:43:32+08:00",
  "resumeHint": "Read state.md, journal.md, then process mailbox message."
}
```

写回 journal 的 mobile confirmation 结构:

```markdown
## 2026-06-13 17:56 · [问答]
- 背景: 手机端提交开发者确认。
- 内容: <开发者原文>
- 来源: mobile-app:<message-id>
```

用于 PRD 门禁或阻塞解除的 mobile 写回必须包含 feature id、target、开发者原文、mobile message id、server 接收时间和 source。回答问题时必须同时追加 journal，并在 `questions.md` 中追加该问题的 answer/resolved 记录；若该问题解除 blocked 状态，必须更新 `state.md` 的 `blocked=false` 和 `updated`。

## 任务 T1: 固化协议与运行时边界

**文件:**
- 创建: `docs/mobile-review-companion/protocol.md`
- 创建: `docs/mobile-review-companion/runtime.md`

- [ ] 步骤1: 写 `protocol.md`，包含 mailbox 目录、消息 schema、事件类型、幂等规则、写回规则、resume 事实源规则。
  核心内容:
  ```markdown
  # Mobile Review Companion Protocol

  Sandtable files remain the durable source of truth. The runtime mailbox is a transport queue.

  ## Mailbox
  - inbox: messages written by agents or mobile clients for the server to process.
  - processed: messages moved after successful processing.
  - outbox: server-originated notifications for agents that do not use MCP.

  ## Durable Writes
  Mobile answers and confirmations must be appended to journal.md and, when applicable, reflected in questions.md or state.md.
  ```
- [ ] 步骤2: 写 `runtime.md`，说明首版只支持本机/局域网 server + 扫码配对，不做公网账号系统。
  核心内容:
  ```markdown
  # Mobile Review Companion Runtime

  The runtime is optional. Installing or updating Sandtable methodology assets does not install runtime dependencies.

  Start:
  npm --prefix runtime/server install
  npm --prefix runtime/server run dev -- --repo "$PWD"

  Stop:
  Press Ctrl-C in the server terminal or send a stop event from the local control endpoint.
  ```
- [ ] 步骤3: 验证 TC1、TC3、TC9、TC10 的文档依据完整。
  运行: `rg -n "source of truth|runtime is optional|Mailbox|Start:|Stop:" docs/mobile-review-companion`
  预期: 每个关键词都能匹配到对应文档段落。

## 任务 T2: 建立 server runtime 工程

**文件:**
- 创建: `runtime/server/package.json`
- 创建: `runtime/server/tsconfig.json`
- 创建: `runtime/server/src/types.ts`
- 创建: `runtime/server/src/paths.ts`
- 创建: `runtime/server/src/index.ts`

- [ ] 步骤1: 创建 `package.json`，明确这是可选 runtime，不属于安装/更新脚本默认依赖。
  ```json
  {
    "name": "@sandtable/mobile-review-server",
    "private": true,
    "type": "module",
    "scripts": {
      "dev": "tsx src/index.ts",
      "build": "tsc -p tsconfig.json",
      "test": "vitest run",
      "typecheck": "tsc -p tsconfig.json --noEmit"
    },
    "dependencies": {
      "@modelcontextprotocol/sdk": "^1.0.0",
      "fastify": "^5.0.0",
      "nanoid": "^5.0.0",
      "ws": "^8.0.0",
      "yaml": "^2.0.0"
    },
    "devDependencies": {
      "@types/node": "^22.0.0",
      "@types/ws": "^8.0.0",
      "tsx": "^4.0.0",
      "typescript": "^5.0.0",
      "vitest": "^2.0.0"
    }
  }
  ```
- [ ] 步骤2: 创建 `tsconfig.json`。
  ```json
  {
    "compilerOptions": {
      "target": "ES2022",
      "module": "NodeNext",
      "moduleResolution": "NodeNext",
      "strict": true,
      "esModuleInterop": true,
      "forceConsistentCasingInFileNames": true,
      "skipLibCheck": true,
      "outDir": "dist"
    },
    "include": ["src/**/*.ts", "test/**/*.ts"]
  }
  ```
- [ ] 步骤3: 写 `types.ts`。
  ```ts
  export type SandtablePhase =
    | "INTAKE" | "RECON" | "OBJECTIVES" | "TESTCASES" | "PLAN"
    | "MENTAL_REHEARSAL" | "REDTEAM" | "IMPL_REHEARSAL"
    | "EVALUATE" | "INTEGRATE" | "VERIFY" | "DONE" | "FEEDBACK";

  export type MessageSource = "agent" | "mobile" | "server";
  export type MessageType =
    | "phase_update" | "document_snapshot" | "question_answer"
    | "confirmation" | "stop";

  export interface MailboxMessage<T = unknown> {
    id: string;
    feature: string;
    source: MessageSource;
    type: MessageType;
    createdAt: string;
    payload: T;
  }

  export interface RuntimePaths {
    repoRoot: string;
    sandtableRoot: string;
    runtimeRoot: string;
    inbox: string;
    processed: string;
    outbox: string;
  }
  ```
- [ ] 步骤4: 写 `paths.ts`，只创建 `.sandtable-runtime/mailbox/*`，不创建/迁移 `docs/sandtable/`。
  ```ts
  import { mkdir } from "node:fs/promises";
  import path from "node:path";
  import type { RuntimePaths } from "./types.js";

  export async function resolveRuntimePaths(repoRoot: string): Promise<RuntimePaths> {
    const runtimeRoot = path.join(repoRoot, ".sandtable-runtime");
    const inbox = path.join(runtimeRoot, "mailbox", "inbox");
    const processed = path.join(runtimeRoot, "mailbox", "processed");
    const outbox = path.join(runtimeRoot, "mailbox", "outbox");
    await Promise.all([inbox, processed, outbox].map((dir) => mkdir(dir, { recursive: true })));
    return {
      repoRoot,
      sandtableRoot: path.join(repoRoot, "docs", "sandtable"),
      runtimeRoot,
      inbox,
      processed,
      outbox
    };
  }
  ```
- [ ] 步骤5: 写 `index.ts` 先能启动、打印监听信息、响应 Ctrl-C。
  ```ts
  import { resolveRuntimePaths } from "./paths.js";

  const repoArgIndex = process.argv.indexOf("--repo");
  const repoRoot = repoArgIndex >= 0 ? process.argv[repoArgIndex + 1] : process.cwd();
  const paths = await resolveRuntimePaths(repoRoot);

  console.log(`Sandtable mobile review server`);
  console.log(`repo: ${paths.repoRoot}`);
  console.log(`mailbox: ${paths.runtimeRoot}`);

  process.on("SIGINT", () => {
    console.log("Sandtable mobile review server stopped");
    process.exit(0);
  });
  ```
- [ ] 步骤6: 验证 TC1、TC9。
  运行: `npm --prefix runtime/server install && npm --prefix runtime/server run typecheck`
  预期: 依赖只安装在 `runtime/server/node_modules`；根安装/更新脚本无改动；typecheck 通过。

## 任务 T3: 实现文件信箱、事件桥、轮询游标和 continuation lease

**文件:**
- 创建: `runtime/server/src/mailbox.ts`
- 创建: `runtime/server/src/events.ts`
- 创建: `runtime/server/src/polling.ts`
- 创建: `runtime/server/src/continuation.ts`
- 创建: `runtime/server/test/mailbox.test.ts`
- 创建: `runtime/server/test/continuation.test.ts`

- [ ] 步骤1: 写 `mailbox.ts` 的 JSON 读写、文件名校验、processed 移动逻辑和 agent->outbox 桥接。
  ```ts
  import { readdir, readFile, rename, writeFile } from "node:fs/promises";
  import path from "node:path";
  import { nanoid } from "nanoid";
  import type { MailboxMessage, MessageSource, MessageType, RuntimePaths } from "./types.js";

  export function createMessage<T>(
    feature: string,
    source: MessageSource,
    type: MessageType,
    payload: T
  ): MailboxMessage<T> {
    return {
      id: `${new Date().toISOString().replace(/[-:.]/g, "")}-${source}-${nanoid(8)}`,
      feature,
      source,
      type,
      createdAt: new Date().toISOString(),
      payload
    };
  }

  export async function enqueueInbox(paths: RuntimePaths, message: MailboxMessage): Promise<string> {
    const file = `${message.id}.json`;
    const target = path.join(paths.inbox, file);
    await writeFile(target, `${JSON.stringify(message, null, 2)}\n`, "utf8");
    return target;
  }

  export async function readInbox(paths: RuntimePaths): Promise<Array<{ file: string; message: MailboxMessage }>> {
    const files = (await readdir(paths.inbox)).filter((file) => file.endsWith(".json")).sort();
    const results = [];
    for (const file of files) {
      const message = JSON.parse(await readFile(path.join(paths.inbox, file), "utf8")) as MailboxMessage;
      results.push({ file, message });
    }
    return results;
  }

  export async function markProcessed(paths: RuntimePaths, file: string): Promise<void> {
    await rename(path.join(paths.inbox, file), path.join(paths.processed, file));
  }

  export async function enqueueOutbox(paths: RuntimePaths, message: MailboxMessage): Promise<string> {
    const file = `${message.id}.json`;
    const target = path.join(paths.outbox, file);
    await writeFile(target, `${JSON.stringify(message, null, 2)}\n`, "utf8");
    return target;
  }

  export async function processInboxOnce(
    paths: RuntimePaths,
    publish: (message: MailboxMessage) => Promise<void>
  ): Promise<number> {
    const entries = await readInbox(paths);
    for (const entry of entries) {
      await publish(entry.message);
      await enqueueOutbox(paths, createMessage(entry.message.feature, "server", entry.message.type, entry.message.payload));
      await markProcessed(paths, entry.file);
    }
    return entries.length;
  }
  ```
- [ ] 步骤2: 写 `events.ts`，为 HTTP/WebSocket/SSE 和测试提供同一个事件总线。
  ```ts
  import { EventEmitter } from "node:events";
  import type { MailboxMessage } from "./types.js";

  export class RuntimeEvents {
    private readonly emitter = new EventEmitter();
    private readonly history: MailboxMessage[] = [];

    async publish(message: MailboxMessage): Promise<void> {
      this.history.push(message);
      this.emitter.emit("message", message);
    }

    list(feature: string): MailboxMessage[] {
      return this.history.filter((message) => message.feature === feature);
    }

    onMessage(listener: (message: MailboxMessage) => void): () => void {
      this.emitter.on("message", listener);
      return () => this.emitter.off("message", listener);
    }
  }
  ```
- [ ] 步骤3: 写 `polling.ts`，定义低成本/免费等待 worker 队列的游标、heartbeat、stop、接力和通知主 agent 的 outbox 消息格式。
  ```ts
  import { readFile, writeFile } from "node:fs/promises";
  import path from "node:path";
  import type { MailboxMessage, RuntimePaths } from "./types.js";

  export interface PollingCursor {
    workerId: string;
    lastSeenMessageId: string | null;
    stopped: boolean;
    heartbeatAt?: string;
  }

  export async function readCursor(paths: RuntimePaths, workerId: string): Promise<PollingCursor> {
    try {
      return JSON.parse(await readFile(path.join(paths.runtimeRoot, "mailbox", "cursors", `${workerId}.json`), "utf8")) as PollingCursor;
    } catch {
      return { workerId, lastSeenMessageId: null, stopped: false };
    }
  }

  export async function writeCursor(paths: RuntimePaths, cursor: PollingCursor): Promise<void> {
    await writeFile(path.join(paths.runtimeRoot, "mailbox", "cursors", `${cursor.workerId}.json`), `${JSON.stringify(cursor, null, 2)}\n`, "utf8");
  }

  export function toMainAgentNotification(message: MailboxMessage, responsibleWorker = "main"): string {
    return JSON.stringify({
      feature: message.feature,
      messageId: message.id,
      type: message.type,
      source: message.source,
      responsibleWorker,
      resumeHint: "Read docs/sandtable/features/<feature>/state.md and journal.md, then process this mobile message."
    });
  }
  ```
- [ ] 步骤4: 写 `continuation.ts`，定义主 agent 阶段性动作结束前必须续租，stop 前不得关闭等待。
  ```ts
  import { mkdir, readFile, writeFile } from "node:fs/promises";
  import path from "node:path";
  import type { RuntimePaths, SandtablePhase } from "./types.js";

  export interface ContinuationLease {
    feature: string;
    phase: SandtablePhase;
    active: boolean;
    stopped: boolean;
    mainAgent: string;
    waitingWorkers: string[];
    workerMode: "poll" | "subscribe" | "host-wait" | "mixed";
    renewAfter: string;
    expiresAt: string;
    resumeHint: string;
  }

  export async function renewContinuation(
    paths: RuntimePaths,
    input: Omit<ContinuationLease, "active" | "stopped" | "renewAfter" | "expiresAt" | "resumeHint">
  ): Promise<ContinuationLease> {
    const now = Date.now();
    const lease: ContinuationLease = {
      ...input,
      active: true,
      stopped: false,
      renewAfter: new Date(now + 5 * 60_000).toISOString(),
      expiresAt: new Date(now + 15 * 60_000).toISOString(),
      resumeHint: "Read docs/sandtable/features/<feature>/state.md and journal.md, then process mailbox message."
    };
    const dir = path.join(paths.runtimeRoot, "session");
    await mkdir(dir, { recursive: true });
    await writeFile(path.join(dir, "continuation.json"), `${JSON.stringify(lease, null, 2)}\n`, "utf8");
    return lease;
  }

  export async function stopContinuation(paths: RuntimePaths): Promise<void> {
    const file = path.join(paths.runtimeRoot, "session", "continuation.json");
    const lease = JSON.parse(await readFile(file, "utf8")) as ContinuationLease;
    await writeFile(file, `${JSON.stringify({ ...lease, active: false, stopped: true }, null, 2)}\n`, "utf8");
  }
  ```
- [ ] 步骤5: 写 `mailbox.test.ts`。
  ```ts
  import { mkdtemp } from "node:fs/promises";
  import os from "node:os";
  import path from "node:path";
  import { describe, expect, it } from "vitest";
  import { RuntimeEvents } from "../src/events.js";
  import { createMessage, enqueueInbox, processInboxOnce, readInbox } from "../src/mailbox.js";
  import { readCursor, toMainAgentNotification, writeCursor } from "../src/polling.js";
  import { resolveRuntimePaths } from "../src/paths.js";

  describe("mailbox", () => {
    it("bridges a generic agent message to events and outbox without MCP", async () => {
      const repo = await mkdtemp(path.join(os.tmpdir(), "sandtable-mailbox-"));
      const paths = await resolveRuntimePaths(repo);
      const events = new RuntimeEvents();
      const message = createMessage("feature-a", "agent", "phase_update", { phase: "PLAN" });
      await enqueueInbox(paths, message);
      await processInboxOnce(paths, (event) => events.publish(event));
      expect(await readInbox(paths)).toHaveLength(0);
      expect(events.list("feature-a")[0].payload).toEqual({ phase: "PLAN" });
    });

    it("creates polling notifications with resume context and does not edit documents on empty polls", async () => {
      const repo = await mkdtemp(path.join(os.tmpdir(), "sandtable-polling-"));
      const paths = await resolveRuntimePaths(repo);
      const cursor = await readCursor(paths, "cheap-worker");
      expect(cursor.stopped).toBe(false);
      await writeCursor(paths, { ...cursor, lastSeenMessageId: "msg-1" });
      const notification = toMainAgentNotification(createMessage("feature-a", "mobile", "confirmation", { target: "prd" }));
      expect(notification).toContain("resumeHint");
    });
  });
  ```
- [ ] 步骤6: 写 `continuation.test.ts`。
  ```ts
  import { readFile } from "node:fs/promises";
  import os from "node:os";
  import path from "node:path";
  import { mkdtemp } from "node:fs/promises";
  import { describe, expect, it } from "vitest";
  import { renewContinuation, stopContinuation } from "../src/continuation.js";
  import { resolveRuntimePaths } from "../src/paths.js";

  describe("continuation lease", () => {
    it("keeps the session active until explicit stop", async () => {
      const repo = await mkdtemp(path.join(os.tmpdir(), "sandtable-continuation-"));
      const paths = await resolveRuntimePaths(repo);
      const lease = await renewContinuation(paths, {
        feature: "feature-a",
        phase: "PLAN",
        mainAgent: "main",
        waitingWorkers: ["cheap-worker-a", "cheap-worker-b"],
        workerMode: "mixed"
      });
      expect(lease.active).toBe(true);
      expect(lease.stopped).toBe(false);
      await stopContinuation(paths);
      const stored = JSON.parse(await readFile(path.join(paths.runtimeRoot, "session", "continuation.json"), "utf8"));
      expect(stored.stopped).toBe(true);
    });
  });
  ```
- [ ] 步骤7: 验证 TC3、TC7、TC11、TC12。
  运行: `npm --prefix runtime/server test -- mailbox`
  预期: 测试通过，证明无 MCP agent 可通过文件信箱同步到 server event/outbox；等待 worker 队列有游标、heartbeat、接力和主 agent 通知 payload；continuation lease 在 stop 前保持 active。

## 任务 T4: 实现 Sandtable 文件读取与写回

**文件:**
- 创建: `runtime/server/src/sandtable.ts`
- 创建: `runtime/server/test/sandtable.test.ts`

- [ ] 步骤1: 写 `sandtable.ts`，读取 feature 文档；缺失文档返回 `missing`，不抛出不可恢复错误；mobile 写回必须能更新 journal/questions/state。
  ```ts
  import { appendFile, readFile, writeFile } from "node:fs/promises";
  import path from "node:path";
  import type { RuntimePaths } from "./types.js";

  export type SandtableDocumentName = "state" | "prd" | "tests" | "plan" | "journal" | "questions";

  export async function readFeatureDocument(
    paths: RuntimePaths,
    feature: string,
    name: SandtableDocumentName
  ): Promise<{ status: "ok"; content: string } | { status: "missing" }> {
    try {
      const content = await readFile(path.join(paths.sandtableRoot, "features", feature, `${name}.md`), "utf8");
      return { status: "ok", content };
    } catch (error) {
      const code = (error as NodeJS.ErrnoException).code;
      if (code === "ENOENT") return { status: "missing" };
      throw error;
    }
  }

  export async function appendMobileJournal(
    paths: RuntimePaths,
    feature: string,
    title: string,
    body: string,
    source: string
  ): Promise<void> {
    const target = path.join(paths.sandtableRoot, "features", feature, "journal.md");
    const receivedAt = new Date().toISOString();
    const entry = `\n## ${receivedAt} · [问答]\n- 背景: 手机端提交开发者确认。\n- Feature: ${feature}\n- 内容: ${title}\n${body}\n- 来源: ${source}\n`;
    await appendFile(target, entry, "utf8");
  }

  export async function recordQuestionAnswer(
    paths: RuntimePaths,
    feature: string,
    questionId: string,
    answer: string,
    source: string
  ): Promise<void> {
    await appendMobileJournal(paths, feature, `Question ${questionId} answered`, `- Answer: ${answer}\n- Resolved: true\n`, source);
    const questionsPath = path.join(paths.sandtableRoot, "features", feature, "questions.md");
    await appendFile(questionsPath, `\n## ${questionId} · mobile answer\n- Answer: ${answer}\n- Source: ${source}\n- Resolved: true\n`, "utf8");
  }

  export async function setBlocked(paths: RuntimePaths, feature: string, blocked: boolean): Promise<void> {
    const statePath = path.join(paths.sandtableRoot, "features", feature, "state.md");
    const current = await readFile(statePath, "utf8");
    const next = current
      .replace(/^blocked: .*/m, `blocked: ${blocked}`)
      .replace(/^updated: .*/m, `updated: ${new Date().toISOString()}`);
    await writeFile(statePath, next, "utf8");
  }
  ```
- [ ] 步骤2: 写 `sandtable.test.ts`，验证手机确认可追溯写回。
  ```ts
  import { mkdir, readFile, writeFile } from "node:fs/promises";
  import os from "node:os";
  import path from "node:path";
  import { describe, expect, it } from "vitest";
  import { resolveRuntimePaths } from "../src/paths.js";
  import { appendMobileJournal, readFeatureDocument } from "../src/sandtable.js";

  describe("sandtable persistence", () => {
    it("appends mobile confirmations to durable journal memory", async () => {
      const repo = await mkdir(path.join(os.tmpdir(), `sandtable-docs-${Date.now()}`), { recursive: true }).then(() => path.join(os.tmpdir(), `sandtable-docs-${Date.now()}`));
      const paths = await resolveRuntimePaths(repo);
      const featureDir = path.join(paths.sandtableRoot, "features", "feature-a");
      await mkdir(featureDir, { recursive: true });
      await writeFile(path.join(featureDir, "journal.md"), "# Journal\n", "utf8");
      await appendMobileJournal(paths, "feature-a", "PRD confirmed", "- 内容: PRD 方向确认\n", "mobile-app:msg-1");
      const journal = await readFeatureDocument(paths, "feature-a", "journal");
      expect(journal.status).toBe("ok");
      expect(journal.status === "ok" ? journal.content : "").toContain("mobile-app:msg-1");
      expect(journal.status === "ok" ? journal.content : "").toContain("Feature: feature-a");
    });
  });
  ```
- [ ] 步骤3: 增加问题回答测试，断言 `questions.md` 追加 `Resolved: true`，需要解除阻塞时 `state.md` 改为 `blocked: false`。
- [ ] 步骤4: 验证 TC5、TC6、TC10。
  运行: `npm --prefix runtime/server test -- sandtable`
  预期: mobile app 来源的确认能落到 durable journal；问题回答能写回 questions/state；缺失文档能被识别为 missing。

## 任务 T5: 暴露 MCP 工具

**文件:**
- 创建: `runtime/server/src/mcp.ts`
- 创建: `runtime/server/src/mcp-stdio.ts`
- 修改: `runtime/server/src/index.ts`
- 创建或扩展: `runtime/server/test/mcp.test.ts`

- [ ] 步骤1: 写 MCP 工具清单，至少包含 `sandtable_sync_phase`、`sandtable_publish_document`、`sandtable_read_mobile_messages`，并把 MCP 消息发布到事件总线和 outbox。
  ```ts
  import type { RuntimePaths } from "./types.js";
  import type { RuntimeEvents } from "./events.js";
  import { createMessage, enqueueInbox, enqueueOutbox, readInbox } from "./mailbox.js";

  export function createMcpHandlers(paths: RuntimePaths, events: RuntimeEvents) {
    return {
      async syncPhase(feature: string, phase: string, summary: string) {
        const message = createMessage(feature, "agent", "phase_update", { phase, summary });
        await events.publish(message);
        await enqueueOutbox(paths, createMessage(feature, "server", "phase_update", message.payload));
        return enqueueInbox(paths, message);
      },
      async publishDocument(feature: string, name: string, content: string) {
        const message = createMessage(feature, "agent", "document_snapshot", { name, content });
        await events.publish(message);
        await enqueueOutbox(paths, createMessage(feature, "server", "document_snapshot", message.payload));
        return enqueueInbox(paths, message);
      },
      async readMobileMessages(feature: string) {
        const messages = await readInbox(paths);
        return messages.filter((item) => item.message.feature === feature && item.message.source === "mobile");
      }
    };
  }
  ```
- [ ] 步骤2: 在 `index.ts` 中初始化 MCP handler；若 MCP transport 接线不可用，仍保持 HTTP/mailbox server 可运行。
  核心代码:
  ```ts
  import { RuntimeEvents } from "./events.js";
  import { createMcpHandlers } from "./mcp.js";
  const events = new RuntimeEvents();
  const mcp = createMcpHandlers(paths, events);
  void mcp;
  ```
- [ ] 步骤3: 写 `mcp-stdio.ts`，用 MCP SDK 的 `McpServer` + `StdioServerTransport` 注册工具。
  核心行为:
  ```ts
  server.registerTool("sandtable_sync_phase", { inputSchema: { feature, phase, summary } }, ...)
  server.registerTool("sandtable_publish_document", { inputSchema: { feature, name, content } }, ...)
  server.registerTool("sandtable_read_mobile_messages", { inputSchema: { feature } }, ...)
  await server.connect(new StdioServerTransport());
  ```
- [ ] 步骤4: 验证 TC2。
  运行: `npm --prefix runtime/server test -- mcp`
  预期: MCP handler 能写入 phase/document 消息，发布到 server event/outbox；同 feature mobile 消息可被读取。

## 任务 T6: 实现局域网 HTTP、配对与事件流

**文件:**
- 创建: `runtime/server/src/http.ts`
- 修改: `runtime/server/src/index.ts`
- 创建: `runtime/server/test/http.test.ts`

- [ ] 步骤1: 写 HTTP API:
  - `GET /health` 返回 server 状态。
  - `GET /pairing?feature=<id>` 返回局域网配对 token、server URL、当前 feature 和可编码成二维码的 payload。
  - `GET /events` 提供 server-sent event 流，让手机端无重启看到 phase/document 更新。
  - `GET /features/:feature/documents/:name` 返回文档内容或 missing。
  - `POST /features/:feature/answers` 接收手机问题回答并写回 journal。
  - `POST /features/:feature/confirmations` 接收手机确认并写回 journal。
  - `POST /stop` 停止 server。
  核心代码:
  ```ts
  import Fastify from "fastify";
  import { nanoid } from "nanoid";
  import type { RuntimePaths } from "./types.js";
  import type { RuntimeEvents } from "./events.js";
  import { appendMobileJournal, readFeatureDocument, recordQuestionAnswer, setBlocked } from "./sandtable.js";

  export async function createHttpServer(paths: RuntimePaths, events: RuntimeEvents, stop: () => Promise<void>) {
    const app = Fastify({ logger: false });
    const pairing = new Map<string, { feature: string; createdAt: string }>();

    app.get("/health", async () => ({ ok: true }));
    app.get("/pairing", async (request) => {
      const feature = ((request.query as { feature?: string }).feature ?? "").trim();
      const token = nanoid(16);
      pairing.set(token, { feature, createdAt: new Date().toISOString() });
      const url = "http://<lan-host>:8765";
      const qrPayload = `sandtable://pair?url=${encodeURIComponent(url)}&token=${encodeURIComponent(token)}&feature=${encodeURIComponent(feature)}`;
      return { url, token, feature, qrPayload };
    });
    app.get("/events", async (_request, reply) => {
      reply.raw.writeHead(200, {
        "content-type": "text/event-stream",
        "cache-control": "no-cache",
        connection: "keep-alive"
      });
      const unsubscribe = events.onMessage((message) => {
        reply.raw.write(`event: ${message.type}\ndata: ${JSON.stringify(message)}\n\n`);
      });
      reply.raw.on("close", unsubscribe);
    });
    app.get("/features/:feature/documents/:name", async (request) => {
      const { feature, name } = request.params as { feature: string; name: "state" | "prd" | "tests" | "plan" | "journal" | "questions" };
      return readFeatureDocument(paths, feature, name);
    });
    app.post("/features/:feature/answers", async (request) => {
      const { feature } = request.params as { feature: string };
      const body = request.body as { token: string; questionId: string; answer: string; messageId: string; resolvesBlocked?: boolean };
      if (pairing.get(body.token)?.feature !== feature) throw new Error("invalid pairing token");
      await recordQuestionAnswer(paths, feature, body.questionId, body.answer, `mobile-app:${body.messageId}`);
      if (body.resolvesBlocked) await setBlocked(paths, feature, false);
      return { ok: true };
    });
    app.post("/features/:feature/confirmations", async (request) => {
      const { feature } = request.params as { feature: string };
      const body = request.body as { token: string; target: string; text: string; messageId: string };
      if (pairing.get(body.token)?.feature !== feature) throw new Error("invalid pairing token");
      await appendMobileJournal(paths, feature, `${body.target} confirmed`, `- 内容: ${body.text}\n`, `mobile-app:${body.messageId}`);
      return { ok: true };
    });
    app.post("/stop", async () => {
      await stop();
      return { ok: true, stopped: true };
    });
    return app;
  }
  ```
- [ ] 步骤2: 在 `index.ts` 启动 HTTP server，默认监听 `127.0.0.1`，允许显式 `--host 0.0.0.0` 开启局域网访问。
  核心代码:
  ```ts
  import { RuntimeEvents } from "./events.js";
  import { createHttpServer } from "./http.js";
  const hostIndex = process.argv.indexOf("--host");
  const host = hostIndex >= 0 ? process.argv[hostIndex + 1] : "127.0.0.1";
  const events = new RuntimeEvents();
  const app = await createHttpServer(paths, events, async () => {
    await app.close();
  });
  await app.listen({ host, port: 8765 });
  console.log(`http: http://${host}:8765`);
  ```
- [ ] 步骤3: 写 `http.test.ts`，覆盖健康检查、pairing payload、token 校验、events、missing 文档、确认/回答写回、停止语义。
- [ ] 步骤4: 验证 TC1、TC4、TC5、TC6、TC8。
  运行: `npm --prefix runtime/server test -- http`
  预期: API 测试通过；pairing 返回 `qrPayload`；无效 token 拒绝写回；events 能收到更新；missing 文档返回 `{ status: "missing" }`；确认和回答写回 journal/questions/state；`POST /stop` 调用 stop callback。

## 任务 T7: 建立 Flutter App 工程与模型

**文件:**
- 创建: `apps/mobile/pubspec.yaml`
- 创建: `apps/mobile/lib/main.dart`
- 创建: `apps/mobile/lib/models.dart`
- 创建: `apps/mobile/lib/api.dart`
- 创建: `apps/mobile/test/models_test.dart`

- [ ] 步骤1: 创建 Flutter 工程结构。若本机有 Flutter CLI，运行:
  运行: `flutter create --platforms=android,ios apps/mobile`
  预期: 生成 Android/iOS 工程骨架。
- [ ] 步骤2: 修改 `pubspec.yaml`，保留最少依赖。
  ```yaml
  name: sandtable_mobile_review
  description: Mobile review companion for Sandtable.
  publish_to: "none"
  version: 0.1.0+1

  environment:
    sdk: ">=3.4.0 <4.0.0"

  dependencies:
    flutter:
      sdk: flutter
    http: ^1.2.0
    mobile_scanner: ^5.0.0
    web_socket_channel: ^3.0.0

  dev_dependencies:
    flutter_test:
      sdk: flutter
    flutter_lints: ^4.0.0
  ```
- [ ] 步骤3: 写 `models.dart`。
  ```dart
  class SandtableDocument {
    const SandtableDocument({required this.name, required this.status, this.content = ''});

    final String name;
    final String status;
    final String content;

    factory SandtableDocument.fromJson(Map<String, dynamic> json) {
      return SandtableDocument(
        name: json['name'] as String? ?? '',
        status: json['status'] as String,
        content: json['content'] as String? ?? '',
      );
    }
  }

  class FeatureSummary {
    const FeatureSummary({required this.id, required this.phase, required this.blocked});

    final String id;
    final String phase;
    final bool blocked;
  }
  ```
- [ ] 步骤4: 写 `api.dart`。
  ```dart
  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'models.dart';

  class SandtableApi {
    SandtableApi(this.baseUrl, this.token);

    final Uri baseUrl;
    final String token;

    Future<SandtableDocument> readDocument(String feature, String name) async {
      final response = await http.get(baseUrl.resolve('/features/$feature/documents/$name'));
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SandtableDocument(
        name: name,
        status: json['status'] as String,
        content: json['content'] as String? ?? '',
      );
    }

    Future<void> submitConfirmation(String feature, String target, String text) async {
      await http.post(
        baseUrl.resolve('/features/$feature/confirmations'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'token': token, 'target': target, 'text': text, 'messageId': DateTime.now().toIso8601String()}),
      );
    }
  }
  ```
- [ ] 步骤5: 写 `models_test.dart`。
  ```dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:sandtable_mobile_review/models.dart';

  void main() {
    test('parses missing document state', () {
      final doc = SandtableDocument.fromJson({'status': 'missing'});
      expect(doc.status, 'missing');
      expect(doc.content, '');
    });
  }
  ```
- [ ] 步骤6: 验证 TC4、TC10 的 App 模型基础。
  运行: `cd apps/mobile && flutter test test/models_test.dart`
  预期: 测试通过；missing 文档不会变成空白错误。

## 任务 T8: 实现 Flutter App 扫码配对与审阅界面

**文件:**
- 创建: `apps/mobile/lib/screens/pairing_screen.dart`
- 创建: `apps/mobile/lib/screens/feature_screen.dart`
- 创建: `apps/mobile/lib/screens/document_screen.dart`
- 创建: `apps/mobile/lib/screens/question_screen.dart`
- 修改: `apps/mobile/lib/main.dart`
- 创建: `apps/mobile/test/widget_test.dart`

- [ ] 步骤1: 写 `pairing_screen.dart`，首版必须支持扫描电脑端 `qrPayload`，手动输入只作为调试入口。
  ```dart
  import 'package:flutter/material.dart';
  import 'package:mobile_scanner/mobile_scanner.dart';

  class PairingScreen extends StatelessWidget {
    const PairingScreen({super.key, required this.onConnect});

    final void Function(Uri serverUrl, String token, String feature) onConnect;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sandtable')),
        body: MobileScanner(
          onDetect: (capture) {
            final raw = capture.barcodes.first.rawValue;
            if (raw == null) return;
            final payload = Uri.parse(raw);
            onConnect(
              Uri.parse(payload.queryParameters['url']!),
              payload.queryParameters['token']!,
              payload.queryParameters['feature']!,
            );
          },
        ),
      );
    }
  }
  ```
- [ ] 步骤2: 写 `document_screen.dart`，显示 missing 状态。
  ```dart
  import 'package:flutter/material.dart';
  import '../models.dart';

  class DocumentScreen extends StatelessWidget {
    const DocumentScreen({super.key, required this.document});

    final SandtableDocument document;

    @override
    Widget build(BuildContext context) {
      final body = document.status == 'missing' ? '尚未生成' : document.content;
      return Scaffold(
        appBar: AppBar(title: Text(document.name)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(body),
        ),
      );
    }
  }
  ```
- [ ] 步骤3: 写 `question_screen.dart`，提交回答/确认。
  核心行为: 文本框非空才启用提交；提交成功后显示已发送。
- [ ] 步骤4: 写 `feature_screen.dart`，入口包括 state、prd、tests、plan、journal、questions。
- [ ] 步骤5: 修改 `main.dart` 串联 Pairing -> Feature -> Document/Question。
- [ ] 步骤6: 写 `widget_test.dart` 覆盖 missing 文档与断开状态。
- [ ] 步骤7: 验证 TC4、TC5、TC6、TC8。
  运行: `cd apps/mobile && flutter test`
  预期: App 渲染测试通过；配对 screen 能解析 `qrPayload`；未生成文档显示"尚未生成"；提交按钮状态符合预期；断开/stop 状态可展示。

## 任务 T9: 增加 agent 同步纪律和常驻轮询说明

**文件:**
- 修改: `skills/using-sandtable/SKILL.md`
- 修改: `plugins/sandtable/skills/using-sandtable/SKILL.md`
- 修改: `locales/en/skills/using-sandtable/SKILL.md`
- 修改: `locales/en/plugins/sandtable/skills/using-sandtable/SKILL.md`
- 修改: `docs/mobile-review-companion/runtime.md`

- [ ] 步骤1: 在中文 `using-sandtable` 中新增一节，不改变现有 Red Flags 表和硬门禁。
  新增文本:
  ```markdown
  ## Mobile Review Companion（可选）

  若当前项目显式启用了 Sandtable mobile review runtime，主 agent 在完成阶段性动作后应同步一次当前 feature 状态：
  - 支持 MCP 时，优先调用 Sandtable MCP 工具同步 phase、文档摘要、待确认事项和阻塞状态。
  - 不支持 MCP 时，按 `docs/mobile-review-companion/protocol.md` 写入 `.sandtable-runtime/mailbox/inbox/`。
  - 手机端确认或回答必须写回 journal/state/questions 后，才可作为 PRD 门禁或阻塞解除依据。
  - 未显式启用 runtime 时，不启动 server、不写 mailbox、不改变 Sandtable 默认流程。
  ```
- [ ] 步骤2: 将同一语义同步到 Codex plugin 版本和英文 locale。
- [ ] 步骤3: 在 `runtime.md` 增加常驻轮询说明。
  核心内容:
  ```markdown
  ## Persistent Polling Agent

  When the runtime is active, the main agent must not treat a phase handoff as session termination. Before ending any phase action, it renews `.sandtable-runtime/session/continuation.json` and hands mailbox waiting to one or more cheap/free waiting workers. Workers may poll, subscribe, block on a host-supported wait primitive, or use any other cheap waiting operation, but they all follow the same mailbox cursor and continuation lease protocol. Empty waits only refresh heartbeat/cursor/lease. A worker reports new `mobile` messages or `stop` events back to the main agent, or relays to a specifically responsible worker, using the notification schema in `docs/mobile-review-companion/protocol.md`. Workers must not edit PRD/tests/plan unless explicitly assigned that responsibility. The main agent handles product decisions by reading `docs/sandtable/features/<feature>/state.md` and `journal.md`, then writes durable decisions itself. Only a computer-side stop, stop mailbox event, or explicit developer stop request may mark the continuation stopped.
  ```
- [ ] 步骤4: 验证 TC7。
  运行: `rg -n "Mobile Review Companion|Persistent Polling Agent|must not edit PRD" skills plugins/sandtable/skills locales/en docs/mobile-review-companion/runtime.md`
  预期: 四份 skill 和 runtime 文档都包含对应纪律。

## 任务 T10: 更新 README / INSTALL / UPDATE 边界

**文件:**
- 修改: `README.md`
- 修改: `INSTALL.md`
- 修改: `UPDATE.md`

- [ ] 步骤1: 在 `README.md` 增加 Mobile Review Companion 小节，明确这是可选 runtime。
  新增文本:
  ```markdown
  ## Mobile Review Companion（可选）

  Sandtable can optionally run a local mobile review companion: a local/LAN server, MCP tools, a file-mailbox fallback for generic agents, and a Flutter app for Android/iOS review.

  The default Sandtable methodology install remains dependency-light and does not install the mobile runtime. See `docs/mobile-review-companion/runtime.md`.
  ```
- [ ] 步骤2: 在 `INSTALL.md` 安装总规则后增加说明。
  新增文本:
  ```markdown
  Mobile Review Companion is optional. The install flow below does not install Node, Flutter, Dart, or runtime dependencies. To enable it, follow `docs/mobile-review-companion/runtime.md` after the methodology assets are installed.
  ```
- [ ] 步骤3: 在 `UPDATE.md` 更新铁律后增加说明。
  新增文本:
  ```markdown
  Updating Sandtable methodology assets does not modify `.sandtable-runtime/`, `runtime/server/node_modules`, Flutter build outputs, or `docs/sandtable/` campaign memory.
  ```
- [ ] 步骤4: 验证 TC9。
  运行: `rg -n "optional|可选|does not install Node|does not modify .*docs/sandtable" README.md INSTALL.md UPDATE.md`
  预期: 三份文档都明确默认安装/更新不安装 runtime、不破坏战役记忆。

## 任务 T11: 端到端验收脚本与手工验证清单

**文件:**
- 创建: `runtime/server/test/e2e.test.ts`
- 创建: `docs/mobile-review-companion/verification.md`

- [ ] 步骤1: 写 `e2e.test.ts`，在临时 repo 中创建 feature 文档，启动 handler，模拟 agent phase_update、mobile confirmation、resume 读取。
  核心断言:
  ```ts
  expect(journal).toContain("mobile-app:");
  expect(journal).toContain("Feature:");
  expect(document.status).toBe("ok");
  expect(inboxAfterProcess).toHaveLength(0);
  expect(events.list("feature-a")).toHaveLength(1);
  expect(outboxMessages[0].type).toBe("phase_update");
  expect(questions).toContain("Resolved: true");
  expect(state).toContain("blocked: false");
  ```
- [ ] 步骤2: 写 `verification.md`，列出人工验证:
  ```markdown
  # Verification

  - TC1: Start server, note URL, stop server.
  - TC2: Sync phase and document through MCP handler; confirm server event stream and app update without restart.
  - TC3: Write mailbox JSON manually; confirm server processes it into event stream and outbox.
  - TC4: Scan computer QR code in mobile app and confirm token-bound local/LAN connection.
  - TC5-TC6: Submit answer and PRD confirmation from mobile; confirm journal/questions/state durable writes.
  - TC7: Confirm polling worker uses cursor, reports mobile messages to main agent only, and respects stop events.
  - TC8: Stop from computer through `/stop` and confirm app disconnects.
  - TC9: Run install/update checks and inspect `docs/sandtable/`.
  - TC10: Delete app cache and resume from repository files.
  - TC11: Complete a phase action with runtime active; confirm continuation lease exists and no terminal completion semantics are emitted.
  - TC12: Run three empty waits across one or more waiting workers, one mobile confirmation, then one stop event; confirm cursor/heartbeat/lease, main-agent notification or worker relay, and stopped lease for all workers.
  ```
- [ ] 步骤3: 验证 TC1-TC10 覆盖闭包。
  运行:
  ```bash
  npm --prefix runtime/server test
  cd apps/mobile && flutter test
  rg -n "TC1|TC2|TC3|TC4|TC5|TC6|TC7|TC8|TC9|TC10|TC11|TC12" docs/mobile-review-companion/verification.md
  ```
  预期: server 测试通过；Flutter 测试通过；verification.md 覆盖 TC1-TC12。

## 任务 T12: 最终一致性检查

**文件:**
- 修改: `docs/sandtable/features/2026-06-13-mobile-review-companion/state.md`
- 修改: `docs/sandtable/features/2026-06-13-mobile-review-companion/journal.md`

- [ ] 步骤1: 检查计划没有占位符。
  运行: `rg -n "T[B]D|待[定]|大[概]|TO[D]O|<具[体]" docs/sandtable/features/2026-06-13-mobile-review-companion/plan.md`
  预期: 无输出。
- [ ] 步骤2: 检查每个 TC 都在计划中出现。
  运行: `for n in 1 2 3 4 5 6 7 8 9 10; do rg -q "TC$n" docs/sandtable/features/2026-06-13-mobile-review-companion/plan.md || exit 1; done`
  预期: 命令退出码为 0。
- [ ] 步骤3: 更新 `state.md` tasks 为 T1-T12，phase 进入 `MENTAL_REHEARSAL`。
- [ ] 步骤4: 在 `journal.md` 追加计划完成记录。
- [ ] 步骤5: 进入 `/sandtable-mental`，让只读子 agent 推演本计划能否闭环。

## 验证矩阵

- TC1: T1, T2, T6, T8, T11
- TC2: T5, T6, T11
- TC3: T1, T3, T5, T11
- TC4: T6, T7, T8, T11
- TC5: T4, T6, T8, T11
- TC6: T4, T6, T8, T9, T11
- TC7: T3, T5, T9, T11
- TC8: T2, T6, T8, T11
- TC9: T1, T2, T10, T12
- TC10: T1, T4, T7, T11
- TC11: T1, T3, T9, T11
- TC12: T1, T3, T9, T11
