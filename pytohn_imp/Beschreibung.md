
---

**START OF COMPLETE, SELF-CONTAINED AI AGENT PROMPT (V6 - Fully Expanded)**

# **Prompt Title:** Design and Blueprint an Ultra-Robust, Adaptive, User-Controlled, and Operationally Sound Local Crypto Trading System

## **I. OVERALL GOAL & CORE PRINCIPLES (V6)**

**Your Task:** You are an expert AI system architect. Generate a **complete, self-contained, and ultra-detailed blueprint** for a highly robust, adaptive, and user-controlled cryptocurrency trading system optimized for **operational stability and clarity**. This system must run locally, learn pragmatically, and offer distinct risk profiles while mitigating complexity where possible. Prioritize **bulletproof core functionality, comprehensive auditability, multi-level risk management with realistic safeguards, transparent user control, state-of-the-art security, and ease of maintenance.**

**Core Principles (V6):**

1.  **Strictly Local & Controlled Autonomy:** Core logic, decision-making, auditing, and state run locally. Provides multiple operational modes (Observe, Semi-Auto, Full-Auto) and three distinct Risk Profiles (Low, Medium, High). User interaction dictates operational boundaries.
2.  **Security by Default & Design:** Multi-layered security is foundational. Assume failures. Prioritize asset/data protection. Secure user interaction points.
3.  **Reliability & Resilience:** Focus on a bulletproof core trading loop. Graceful error handling. Configurable Portfolio Emergency Halt (best-effort). Robust automated backups/exports.
4.  **Test/Live Parity & Separation:** Strict, verifiable separation (Databases, Log Files, Audit Trail, Processes). Accurate Test mode simulation reflecting risk profile effects.
5.  **Data-Driven & Adaptive (Risk-Aware & Supervised):** Utilizes public data/APIs. Dynamic strategy selection based on risk-adjusted performance (combining backtest results and live feedback), influenced by the selected Risk Profile. Optimization process is user-controllable and acknowledges limitations (especially concerning leverage backtesting).
6.  **Transparency, Monitorability & Auditability:** Clear insights via structured logs, hierarchical interactive dashboards with prominent integrated risk warnings and filtering capabilities, and a complete, immutable audit trail distinguishing System vs. User actions and operating modes/profiles.
7.  **Modularity & Maintainability (Pragmatic):** Clear modules with well-defined responsibilities, favoring stability and clarity over excessive granularity where appropriate.
8.  **Ease of Setup, Use & Control:** Straightforward setup, configuration, and monitoring. Intuitive interface for selecting modes, managing risk settings, approving actions, and understanding leverage implications. Clear documentation is essential. Multi-step confirmations ("Save Stages") for critical actions enhance safety.
9.  **Modern Best Practices (Proven & Stable):** Employ robust and widely accepted patterns (asynchronous programming where beneficial, internal event queue for decoupling, structured logging, ORM for database interaction), focusing on reliability and maintainability.
10. **Integrated Multi-Level Risk Management (Core & Realistic):** Configurable risk controls (per-trade risk percentage, position sizing aware of risk profile and leverage, prioritization of exchange-native stop-loss mechanisms, portfolio drawdown monitoring, and a configurable emergency halt procedure) are central to *all* trading logic.
11. **User in Control:** The user *always* retains ultimate control via operational modes, risk profiles, approval steps, halt commands, and clear visibility into system actions. Leverage requires explicit multi-stage activation and constant, explicit risk awareness provided through the UI.

---

## **II. DETAILED SYSTEM BLUEPRINT REQUIREMENTS (V6)**

### **1. Security Architecture ("Security by Default")**

*   **Instruction:** Define the multi-layered security architecture. Specify mechanisms and technologies for each component. Emphasize audit trail integrity, secure key handling, securing user interactions related to risk/leverage changes, and implementing confirmation steps.

    | Component                     | Detailed Security Measure & Implementation Instruction                                                                                                                                                                                                                                                                                          | Example / Specification                                                                                                                                                                                             |
    | :---------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
    | **API Keys & Master PIN**     | Store API keys **exclusively** in an encrypted format (AES-256-GCM recommended) within a dedicated file (e.g., `secrets.yaml.enc`) or secure OS keychain. **Never store keys in plain text.** Decryption requires a **Master PIN**, which itself should be securely stored (e.g., bcrypt hash). Prompt the user for the Master PIN only when necessary (e.g., Live Mode activation, potentially critical confirmations). Decrypt API keys **just-in-time** for API client instantiation or calls. **Immediately clear the decrypted key from memory** after use (`del decrypted_key`). Ensure keys are **never committed** to version control systems. | Use Python's `cryptography` library. Store bcrypt hash of Master PIN. Prompt "Enter Master PIN:". Verify using `bcrypt.checkpw(...)`. Use `Fernet` for AES-GCM. `key = Fernet(derive_key(pin)); decrypted = key.decrypt(encrypted_api); use(decrypted); del decrypted`. |
    | **Test/Live Separation**      | Implement **physically separate database tables** for test and live data (e.g., `audit_trail_test` vs `audit_trail_live`, `trades_test` vs `trades_live`). Use **distinct process environment variables or configuration flags** (`SYSTEM_MODE=TEST` or `SYSTEM_MODE=LIVE`) loaded at startup to control execution paths. Utilize **separate log files** (e.g., `test.log`, `live.log`). Ensure **no code path** can accidentally use live credentials, access live tables, or execute live trades when in test mode. The **`audit_trail` table must have a mandatory `mode` field** ('TEST', 'LIVE', 'SYSTEM'). | Check `config.system_mode == 'LIVE'` before accessing live resources. Use conditional logic for DB connection strings and log handlers based on mode. Audit entries must accurately reflect the mode.                               |
    | **Mode/Risk Activation**      | Require **Master PIN confirmation** for the initial activation of Live Mode in each session. Implement **multi-step confirmations (Save Stages)** with clear textual warnings and require acknowledgment (e.g., checkbox or typing confirmation phrase) for sensitive actions like switching to a higher Risk Profile (Medium -> High), enabling Leverage functionality, or overriding critical system halts. **Log every confirmation attempt and its outcome** (success/failure) to the `audit_trail`, clearly marking the action initiator with `actor='USER'`. Consider session timeouts for UI inactivity in Live mode. | UI Prompt: "Confirm switch to HIGH Risk Profile? This significantly increases potential losses. Enter Master PIN and check box: [ ] I understand and accept the increased risks. -> Confirm". Log `AUDIT - RISK_MODE_CHANGE_CONFIRMED (actor=USER, profile=High)`. |
    | **Strategy Execution**        | Execute strategy code within a **sandbox environment** to prevent unintended side effects. A simplified sandbox can involve running strategy classes (inheriting from `BaseStrategy`) within the main trusted process, ensuring they only receive market data (e.g., Pandas DataFrame) and return a defined dictionary structure (`{'signal': 'BUY'/'SELL'/'HOLD', 'stop_loss': price (optional)}`). Strategies **must not** have direct access to file system I/O, network sockets, or system command execution. Pass necessary configuration or indicators via constructor or method arguments. | If using pure Python strategies within the main process, rely on code review and clear interface definitions. For higher security with untrusted strategies, consider `RestrictedPython` or process isolation (adds complexity).                                |
    | **Logging & Auditing**        | Implement **append-only file logging** using a structured format like JSON. Use rotating file handlers to manage log file size (e.g., `logs/system.log`, `logs/test.log`, `logs/live.log`). The **`audit_trail` database table is the primary, immutable record** of critical system events and user actions. Application logic (or DB triggers if feasible and desired) must enforce append-only behavior (no updates/deletes). Audit entries **must include** timestamp, `mode` (TEST/LIVE/SYSTEM), `actor` ('SYSTEM'/'USER'), `action_type`, `status` (SUCCESS/FAILURE/INFO/etc.), `risk_profile` (at time of action), and a detailed JSON `details` blob. **Ensure no sensitive data** (API keys, PINs) is ever written to *any* log or audit trail entry. | Use Python's standard `logging` module with `JSONFormatter` and `RotatingFileHandler`. Implement a dedicated `db_manager.log_audit(mode, actor, action, status, risk_profile, details)` function that only performs INSERT operations on the `audit_trail` table. |
    | **System Recovery**           | Utilize database transactions (with Write-Ahead Logging - `PRAGMA journal_mode=WAL;` for SQLite) for all state-modifying operations (trades, wallet updates, config changes). The detailed `audit_trail` serves as a guide for manual or potentially automated recovery. Implement a **startup consistency check routine** in `main_controller.py` that verifies database integrity and cross-references the state (e.g., `PENDING` live trades in `trades_live`) against the last relevant entries in the `audit_trail` to detect interrupted operations. Use automated backups (see Section 14) for disaster recovery. | Use `try...except...finally` blocks with `db_connection.begin()`, `db_connection.commit()`, `db_connection.rollback()`. Startup check queries `trades_live` where `status = 'SUBMITTED'` and cross-references with `audit_trail` for API responses or reconciliation results. |
    | **Config Security**           | Store non-sensitive configuration in a human-readable file (`config.yaml`). Store sensitive data (encrypted API keys, hashed Master PIN) separately (`secrets.yaml.enc`). Use a validation library (e.g., `Pydantic`) to parse and validate the configuration structure and types upon system startup. Fail fast if configuration is invalid. | `class ConfigModel(BaseModel): ...; config = ConfigModel.parse_obj(yaml.safe_load(open('config.yaml')))`                                                                               |
    | **Audit Trail Integrity**     | Primarily enforce append-only behavior via application logic within the `db_manager.log_audit` function. Optionally, add database triggers (if using PostgreSQL/MySQL) to prevent `UPDATE` or `DELETE` operations on the `audit_trail` table for added security. Schedule regular, automated exports of the audit trail data (see Section 14). | The `log_audit` function strictly uses `INSERT`. Optional PostgreSQL trigger: `CREATE TRIGGER audit_log_no_modify BEFORE UPDATE OR DELETE ON audit_trail FOR EACH ROW EXECUTE FUNCTION prevent_modify();`.                    |
    | **User Action Security**      | All UI actions that modify system state (mode change, risk profile change, leverage toggle, trade/strategy approvals, halt commands) **must** be processed through the `user_command_handler`, require confirmation (potentially re-authentication with PIN based on session security), and be **explicitly logged** to the `audit_trail` with `actor='USER'`. | UI Button Click -> Confirmation Modal (explains action & risk) -> [Optional PIN] -> Submit Command -> `user_command_handler` validates -> `db_manager.log_audit(actor='USER', ...)` -> Execute action. |
    | **Leverage Activation Security**| Implement **multi-stage activation** for leverage: 1. `allow_leverage: true` must be set in `config.yaml`. 2. User must explicitly toggle leverage 'ON' via the UI. This toggle action triggers a modal dialog requiring the user to read a detailed **EXTREME RISK WARNING**, acknowledge understanding (e.g., by typing a confirmation phrase like 'CONFIRM LEVERAGE'), and potentially re-enter the Master PIN. **Log the entire activation sequence**, including the confirmation, to the `audit_trail` with `actor='USER'`. | UI: Toggle Leverage -> Modal shows detailed risks. User types 'CONFIRM LEVERAGE' -> Enters PIN -> Submit. Log `AUDIT - LEVERAGE_ENABLED (actor=USER, confirmation_text='CONFIRM LEVERAGE')`. |

### **2. System Structure & Modularity (Pragmatic)**

*   **Instruction:** Define a streamlined but logical directory structure. Consolidate closely related functions where sensible to reduce interface complexity, while maintaining clarity of purpose for each module.

    ```plaintext
    /robust_adaptive_trading_system/
    ├── config/
    │   ├── config.yaml             # Main config: modes, risk profiles & params, leverage settings, paths, intervals, features (e.g., correlation enable)
    │   └── secrets.yaml.enc        # Encrypted API keys, hashed Master PIN
    ├── core/
    │   ├── main_controller.py      # **Orchestrator:** Initializes modules, runs main async event loop, manages system state (mode, risk profile, halt status), handles internal event queue (`asyncio.Queue`), schedules background tasks (backup, export, reconciliation), processes validated commands from `user_command_handler`.
    │   ├── trading_engine.py       # **Core Trading Logic:** Consumes data events, retrieves active strategy, generates trading signals, performs **risk profile checks/filtering**, checks **portfolio drawdown against limits**, coordinates trade execution/proposal with `WalletManager`, handles semi-auto proposal workflow state.
    │   ├── wallet_manager.py       # **Execution & State Management:** Manages local view of wallet balances (test/live), performs **configurable Just-In-Time (JIT) balance/margin checks** via API, calculates **risk/leverage-aware position sizes**, places/simulates orders (including exchange-native SL & leverage parameters), updates local wallet state after actions/reconciliation, calculates and updates portfolio value/drawdown state.
    │   ├── strategy_optimizer.py   # **Optimization Orchestrator:** Uses external backtesting libraries (`backtrader`/`vectorbt`), incorporates live performance feedback, selects strategies based on **target risk profile constraints**, handles strategy proposal/approval workflow based on configuration.
    │   └── user_command_handler.py # **Command Processor:** Receives raw commands from the UI, validates them against current system state/permissions, potentially requires PIN re-auth, executes valid commands by interacting with `main_controller` or other core modules, ensures actions are logged via `db_manager`.
    ├── data_pipeline/
    │   ├── data_fetcher.py         # Central point for requesting market data. Delegates to specific scrapers or API clients. Manages data caching mechanism.
    │   ├── scrapers/               # Modules for scraping public websites (e.g., Yahoo Finance, CoinGecko Web) respecting `robots.txt` and rate limits.
    │   └── api_clients/            # Modules for interacting with exchange APIs: dedicated client for **Read-Only** operations (fetching balance, margin, order status) and another for **Execution** (placing/canceling orders).
    ├── strategies/
    │   ├── base_strategy.py        # Abstract base class defining the interface for all strategies (`generate_signal` method returning `{'signal': ..., 'stop_loss': ...}`).
    │   ├── indicators/             # Library of reusable technical indicator calculation functions (using `pandas-ta` or similar).
    │   └── strategy_library/       # Collection of concrete strategy implementations (e.g., `strategy_sma_cross.py`, `strategy_rsi_divergence.py`). Strategies might optionally include metadata (e.g., suggested risk profiles, description).
    ├── ui_dashboard/
    │   ├── dashboard_app.py        # Main application file for the web dashboard (using Dash or Streamlit). Initializes layout and callbacks.
    │   ├── layout_definitions.py   # Defines the structure of the UI: Persistent Status Bar, Main Tabs/Sections (Overview, Trades, Strategies/Risk, Audit), definition of Confirmation Modal dialogs. Focus on hierarchical information presentation.
    │   ├── components/             # Reusable UI elements: Filterable data tables, strategy approval cards, risk profile selectors, clear warning banner components, confirmation modal logic.
    │   └── callbacks.py            # Contains the logic for handling user interactions (button clicks, dropdown changes, filtering), updating UI elements based on system events/data changes, sending commands to `user_command_handler`, and managing modal dialog visibility/state.
    ├── database/
    │   ├── schema_v6.sql           # SQL file defining the complete database schema (all tables, columns, constraints, indexes) for version 6.
    │   ├── db_manager.py           # Abstraction layer for all database operations. Uses an ORM like SQLAlchemy to interact with the database. Provides methods for CRUD operations and the critical `log_audit` function. Handles DB connections.
    │   └── migrations/             # Directory for database migration scripts (using Alembic recommended) to manage schema changes over time.
    ├── operations/
    │   ├── run_backup.py           # Standalone script (or callable function) for performing automated backups of the database and configuration files.
    │   ├── run_export.py           # Standalone script (or callable function) for exporting specified data (audit trail, trades) to CSV/JSON files.
    ├── logs/                         # Directory where rotating log files (`system.log`, `test.log`, `live.log`) are stored.
    ├── cache/                        # Directory for storing cached data from the data pipeline.
    ├── backups/                      # Target directory where automated backup archives are saved.
    ├── exports/                      # Target directory where automated data exports are saved.
    ├── tests/                        # Contains unit and integration tests for all core modules, focusing on core loop, risk management logic, wallet interactions, and audit logging.
    │   └── ...
    ├── requirements.txt              # Lists all Python dependencies with specific versions for reproducibility.
    └── README.md                   # **Essential Documentation:** Comprehensive guide covering system goals, architecture overview, detailed setup instructions, configuration parameters explanation (modes, risk profiles, leverage, emergency halt), how to operate the system, dashboard usage, security considerations, backup and restore procedures. **Must include explicit, prominent warnings about leverage risks.**
    ```

### **3. Operational Modes (Clear User Control Levels)**

*   **Instruction:** Clearly define the distinct operational modes available to the user, detailing system behavior in each mode.

    1.  **`Observe` Mode:**
        *   **System Actions:** Runs the complete data pipeline (fetching, caching), performs strategy selection/optimization based on configuration (can also be user-triggered via UI), generates trading signals based on the selected strategy and incoming data, performs all associated risk assessments (per-trade risk calculation, portfolio drawdown check vs limits), and performs Just-In-Time balance/margin checks (if Live connection configured and enabled).
        *   **Trading Behavior:** **Strictly NO trades** are executed, neither simulated in the test wallet nor live on an exchange. Trade proposals are **not** generated for user approval.
        *   **Auditing:** All intended actions, generated signals, risk check outcomes, and JIT check results are meticulously logged to the `audit_trail` table. The `action_type` should clearly indicate the observational nature (e.g., `SIGNAL_GENERATED_OBSERVE`, `RISK_CHECK_PASS_OBSERVE`, `JIT_CHECK_SUCCESS_OBSERVE`). The `mode` field will be 'TEST' or 'LIVE' depending on which data context is being observed.
        *   **UI Display:** The dashboard displays the current system state, market data, the currently selected strategy for each asset, potential trading signals as they are generated ("What the bot *would* do"), performance tracking based on these hypothetical trades, and risk metrics.
        *   **Purpose:** Allows the user to safely monitor the system's decision-making logic, strategy performance in real-time market conditions, and risk assessments without any financial exposure or commitment. Ideal for initial setup, testing new strategies, or passive monitoring. This should be the default mode after installation.
    2.  **`Semi-Automatic` Mode:**
        *   **System Actions:** Performs all actions as described in `Observe` Mode (data fetching, optimization, signal generation, risk assessment, JIT checks).
        *   **Trading Behavior:** When a valid trading signal is generated and passes all relevant risk checks (per-trade risk, portfolio drawdown), the `trading_engine` **does not execute immediately**. Instead, it generates a detailed **"trade proposal"**.
        *   **Trade Proposal:** This proposal contains all relevant information: Asset, Action (Buy/Sell), Signal Source (Strategy Name), Entry Price (estimated), Calculated Position Size, Stop-Loss Level (if provided), Calculated Risk Percentage, Leverage Factor (if High Risk mode & enabled), Estimated Required Margin (if leverage), current Portfolio Drawdown. The proposal's status is marked as 'PENDING_APPROVAL' (potentially stored in a temporary state or linked via `audit_trail`). An internal event (`TRADE_PROPOSAL_READY`) is published.
        *   **User Interaction:** The UI prominently displays the pending trade proposal(s), usually in a dedicated section. The user **must explicitly click 'Approve' or 'Reject'** for each proposal.
        *   **Auditing:** The generation of the proposal is logged (`action_type=TRADE_PROPOSAL_GENERATED`). The user's decision is logged (`action_type=TRADE_PROPOSAL_REVIEWED`, `actor=USER`, `status=Approved/Rejected`).
        *   **Execution Path:** If the user approves the proposal, an internal event (`TRADE_PROPOSAL_RESOLVED`, status=Approved) is published. The `trading_engine` receives this and instructs the `wallet_manager` to proceed with the trade execution (simulated or live). If rejected, the proposal is discarded, and the rejection is logged.
        *   **Strategy Approval:** Similarly, if `require_strategy_approval` is configured, proposals generated by the `strategy_optimizer` follow this Approve/Reject workflow via the UI.
        *   **Purpose:** Keeps the user in the loop for every single trading decision and strategy change, allowing final manual confirmation while benefiting from the system's analysis and signal generation capabilities. Provides a balance between automation and control.
    3.  **`Fully-Automatic` Mode:**
        *   **System Actions:** Performs all actions autonomously based on the current configuration (Risk Profile, strategy settings, etc.). Data fetching, optimization, signal generation, risk assessment, JIT checks all run automatically.
        *   **Trading Behavior:** When a valid trading signal passes all risk checks, the `trading_engine` **immediately** instructs the `wallet_manager` to execute the trade (simulated or live) without requiring user intervention.
        *   **Strategy Updates:** Strategy optimization runs automatically according to schedule (unless configured otherwise), and the newly selected active strategy is applied directly (unless `require_strategy_approval` is explicitly set even for this mode, which would be unusual but possible).
        *   **User Monitoring & Control:** The user can (and should) continuously monitor the system's performance, risk metrics, and audit trail via the dashboard. The user retains the ability to:
            *   Manually trigger a system-wide **HALT** via the UI.
            *   **Change the Risk Profile** (requires confirmation, moving to lower risk is generally safer).
            *   **Switch back** to `Semi-Automatic` or `Observe` mode at any time.
            *   Manually trigger optimization runs.
        *   **Purpose:** Allows for hands-off autonomous trading according to the pre-defined rules and risk parameters. This mode requires the highest level of user confidence in the system's configuration and robustness. Significant risks are involved if not configured and monitored properly.

*   **Mode Switching:** The user selects the desired operational mode via UI controls (e.g., radio buttons or a dropdown). Switching modes, especially towards modes with higher autonomy (`Observe` -> `Semi-Auto` -> `Full-Auto`), should trigger a confirmation dialog explaining the implications and risks. All mode changes initiated by the user are logged to the `audit_trail` with `actor='USER'`. The current mode is persistently displayed in the UI status bar.

### **4. Risk Management System (Multi-Level, Realistic Safeguards)**

*   **Instruction:** Define the comprehensive, multi-level risk management system. Detail the Risk Profiles, leverage handling specifics, the configurable Emergency Halt mechanism, per-trade risk calculations, and stop-loss prioritization. Emphasize realistic expectations and warnings.

    *   **Risk Profiles (Configurable Basis):** The system operates under one of three user-selected Risk Profiles, defined in `config.yaml`. Each profile dictates key risk parameters:
        *   **`Low` Risk Profile:**
            *   `risk_per_trade_percent:` Very small value (e.g., 0.25% - 0.5% of portfolio value).
            *   `max_portfolio_drawdown_limit:` Strict limit triggering Emergency Halt (e.g., 5% - 10% from peak).
            *   `optimizer_max_strategy_drawdown:` Strict constraint for strategy selection during backtesting (e.g., < 15%).
            *   `allowed_strategy_tags:` Optional list restricting strategy selection to those explicitly tagged as 'LowRisk' or similar.
            *   `leverage_allowed:` **false (Hardcoded/Non-configurable).**
            *   *Goal:* Capital preservation focus, minimal volatility exposure.
        *   **`Medium` Risk Profile:**
            *   `risk_per_trade_percent:` Moderate value (e.g., 0.75% - 1.5%).
            *   `max_portfolio_drawdown_limit:` Moderate limit (e.g., 15% - 25%).
            *   `optimizer_max_strategy_drawdown:` Moderate constraint (e.g., < 30%).
            *   `allowed_strategy_tags:` Allows strategies tagged 'LowRisk', 'MediumRisk'.
            *   `leverage_allowed:` **false (Hardcoded/Non-configurable).**
            *   *Goal:* Balance between growth potential and controlled risk, standard trading strategies.
        *   **`High` Risk Profile:**
            *   `risk_per_trade_percent:` Higher value (e.g., 2% - 3%, requires user confirmation if set above a threshold like 2.5%).
            *   `max_portfolio_drawdown_limit:` Higher limit (e.g., 30% - 50%, requires user confirmation if set above a threshold like 40%).
            *   `optimizer_max_strategy_drawdown:` Looser constraint (e.g., < 50%).
            *   `allowed_strategy_tags:` Allows all strategies, including those tagged 'HighRisk' or untagged.
            *   `leverage_allowed:` **true (Enables the *possibility* of using leverage, actual usage requires further steps).**
            *   *Goal:* Maximizing potential returns, accepting higher volatility and drawdown risk, enabling advanced features like leverage *if explicitly configured and activated*. Requires experienced user oversight.

    *   **Leverage Management (High Risk Mode Only & Multi-Stage Activation):**
        *   **Prerequisite:** System must be in `High` Risk Profile.
        *   **Configuration:** Requires `allow_leverage: true` in `config.yaml` AND specific leverage multipliers defined per asset pair (e.g., `leverage_per_asset: {'BTC-USDT': 3, 'ETH-USDT': 5}`). Default is 1x (no leverage).
        *   **Activation:** User must *explicitly* toggle leverage 'ON' in the UI. This action triggers a **multi-stage confirmation**:
            1.  Display **detailed EXTREME RISK WARNING** explaining margin, liquidation, potential for amplified losses exceeding initial capital (if applicable to exchange/instrument).
            2.  Require user to acknowledge understanding (e.g., type "CONFIRM LEVERAGE").
            3.  Require Master PIN re-entry.
        *   **UI Indication:** When leverage is active (globally enabled AND configured for any trading pair), display a **constant, prominent, unambiguous visual warning** (e.g., blinking red "LEVERAGE ACTIVE" banner) in the status bar. Open positions using leverage must also be clearly marked.
        *   **Wallet Manager Role:** When calculating position size and placing orders for configured assets (in High mode with leverage activated):
            *   Perform JIT check for *both* available balance *and* available margin balance via API.
            *   Calculate required margin based on target position value and configured leverage (handle exchange-specific calculations like Cross/Isolated margin if possible, state assumptions). Reject if insufficient margin.
            *   Include leverage parameters in the `place_order` API call as required by the exchange.
        *   **Backtesting Limitation:** **Crucially acknowledge:** Backtesting leverage accurately is extremely difficult due to unpredictable liquidation cascades and funding rates. The system's backtester (via external library) may not fully simulate these effects. Optimization results for strategies intended for leverage **must be treated with extreme skepticism.** The optimizer logic should ideally penalize strategies whose backtested performance relies solely on leverage, or require validation without leverage. This limitation must be stated clearly in documentation and potentially in the UI near leverage controls.
        *   **Auditing:** Log every step: leverage config load, multi-stage activation attempt/success (`actor=USER`), JIT margin checks, leverage used in size calculation, leverage parameter in API call attempt/success.

    *   **Portfolio Emergency Halt ("Portfolio Drawdown Emergency Halt"):**
        *   **Purpose:** A best-effort mechanism to limit catastrophic portfolio losses based on a predefined drawdown threshold, NOT a guarantee against losses.
        *   **Monitoring:** The `trading_engine` (or a dedicated check within the main loop) constantly compares the `current_portfolio_value_usd` against the `peak_portfolio_value_usd` (both stored and updated in `portfolio_risk_state` by `wallet_manager` after trades/reconciliation).
        *   **Trigger:** `(peak_portfolio_value_usd - current_portfolio_value_usd) / peak_portfolio_value_usd` EXCEEDS the `max_portfolio_drawdown_limit` defined for the **currently active Risk Profile**.
        *   **Configurable Action (`emergency_halt_action` in `config.yaml`):** Determines the system's response upon trigger:
            *   `'HALT_ONLY'` (**Safest Default Recommendation**):
                1.  Log `AUDIT - EMERGENCY_HALT_TRIGGERED (Reason=DrawdownLimitExceeded, Limit={limit}%, Current={current}%)` - CRITICAL Level.
                2.  Set `is_trading_halted = TRUE`, `is_emergency_stop_active = TRUE`, `halt_reason = 'EMERGENCY_DRAWDOWN'` in `portfolio_risk_state`.
                3.  Immediately stop processing new trade signals in `trading_engine`.
                4.  Update UI prominently: "EMERGENCY HALT - DRAWDOWN LIMIT REACHED - MANUAL REVIEW REQUIRED".
            *   `'CANCEL_ORDERS_AND_HALT'`:
                1.  Perform all steps from `HALT_ONLY`.
                2.  (Live Mode Only) Instruct `wallet_manager` to attempt to **cancel all open orders** across all managed assets via API. Log attempts and success/failure for each order cancellation to `audit_trail`.
            *   `'MARKET_CLOSE_ALL_AND_HALT'`:
                1.  **Requires explicit acknowledgment/confirmation during configuration** due to high risk. Store confirmation in config or initial setup log.
                2.  Perform steps from `CANCEL_ORDERS_AND_HALT`.
                3.  (Live Mode Only) Instruct `wallet_manager` to attempt to **close all open positions** for all managed assets using **MARKET orders** via API. Log attempts and success/failure/fill details for each market close order. **Include warnings about potential severe slippage in logs and UI.**
        *   **State:** The `HALTED` state prevents *new* trades. Reconciliation and monitoring continue.
        *   **Reset:** Requires **manual user intervention** via a dedicated "Clear Emergency Halt" button in the UI. This action requires **confirmation and Master PIN entry**. It resets `is_emergency_stop_active` and `is_trading_halted` flags (potentially sets `halt_reason` to 'MANUAL_RESET'). The user must then manually re-select an operational mode (likely starting with Observe or Semi-Auto). Log reset action (`actor=USER`).

    *   **Per-Trade Risk:** Calculated by `wallet_manager` before each trade attempt. Based on `risk_per_trade_percent` (from active Risk Profile), estimated portfolio value, leverage factor (if High mode & active/configured), and the distance to the stop-loss price (if provided by strategy). Ensures a single trade does not exceed the defined risk threshold.
    *   **Stop-Loss:** `wallet_manager` prioritizes using **exchange-native stop-loss order parameters** (`stopPrice` for stop-market/stop-limit, or OCO orders if supported by API and configured) when placing the initial trade order. This is more reliable than local monitoring. Configuration (`config.yaml`) should indicate per-exchange capabilities. If strategy provides an SL and exchange supports it, use it. If not supported, the trade might proceed without an SL order placed by the bot (user must be aware). Local SL monitoring is discouraged due to reliability issues but could be a configurable fallback if absolutely necessary (adds complexity). Log the SL method used/attempted.

### **5. Data Pipeline (Robust & Audited)**

*   **Instruction:** Detail the robust, compliant data pipeline focusing on reliability and clear audit logging of its operations.

    *   **Compliance:** Strictly adhere to `robots.txt` for all web scraping activities. Use `urllib.robotparser` before making requests to any new path on a domain. If disallowed, log a warning to `audit_trail` (`action_type=DATA_FETCH_REFUSED`, `status=WARNING`) and skip that source.
    *   **Rate Limiting:** Implement polite delays between consecutive requests to the same domain (e.g., `time.sleep(random.uniform(1.5, 4.0))`). Respect `Retry-After` headers if provided by APIs or web servers (HTTP 429). Log rate limiting events (`action_type=DATA_FETCH_RATE_LIMITED`, `status=WARNING`).
    *   **User-Agent:** Set a descriptive and unique User-Agent string for requests (e.g., `"RobustAdaptiveTradingBot/1.0 (+your_contact_info_or_project_url)"`).
    *   **Error Handling:** Implement robust error handling for network issues (timeouts, connection errors) and unexpected responses (HTTP 5xx errors). Use retries with exponential backoff strategy (e.g., wait 1s, 2s, 4s, 8s before retrying). Log persistent failures after exhausting retries (`action_type=DATA_FETCH_FAILURE`, `status=FAILURE`).
    *   **Source Fallback:** Configure primary and secondary data sources per asset/data type in `config.yaml`. If the primary source fails persistently (e.g., after retries), automatically attempt to fetch data from the secondary source. Log the fallback attempt and its outcome (`action_type=DATA_FETCH_FALLBACK`, `details={'from': 'primary', 'to': 'secondary'}`).
    *   **Caching:** Implement a local file-based cache (e.g., in `cache/` using JSON or Feather format) to store successfully fetched data. Cache keys should include source, asset, timeframe, and timestamp/date. Before attempting a live fetch, check if valid (non-expired) data exists in the cache. Cache validity determined by configurable duration (`cache_duration_minutes` in `config.yaml`).
    *   **Auditing:** Log key data pipeline actions to `audit_trail` with `mode='SYSTEM'`:
        *   `DATA_FETCH_ATTEMPT`: Before contacting source. `details={'source': ..., 'asset': ...}`.
        *   `DATA_FETCH_SUCCESS`: After successful fetch. `details={'source': ..., 'asset': ..., 'cached': True/False, 'records_fetched': ...}`.
        *   `DATA_FETCH_FAILURE`: After failed attempt (post-retries). `details={'source': ..., 'asset': ..., 'error': ...}`.
        *   `DATA_FETCH_REFUSED`: If `robots.txt` disallows. `details={'source': ..., 'url': ...}`.
    *   **Focus:** Prioritize reliability for 1-2 core web scraping sources (e.g., Yahoo Finance) and 1-2 core Read-Only API sources (e.g., Binance for price data fallback and essential JIT checks). Avoid relying on too many unstable sources.

### **6. Wallet System (Configurable JIT, Leverage Aware, Reconciled)**

*   **Instruction:** Define wallet management emphasizing configurable JIT checks, robust leverage handling, accurate sizing, detailed auditing, and the importance of the reconciliation loop.

    *   **Local State View:** The database tables `wallets_test` and `wallets_live` primarily store the system's *last known state* based on its own simulated actions (Test) or submitted/reconciled actions (Live). They are *not* guaranteed to be a perfect real-time mirror of the exchange, especially if manual trades occur outside the bot or if JIT checks are disabled.
    *   **Live - Just-In-Time (JIT) Checks (Configurable):**
        *   **Configuration:** `require_jit_checks: true | false` in `config.yaml` (Default: `true`). Allows users on unreliable connections or with very stable balances to potentially disable it, accepting the risk.
        *   **Execution:** If `true`, *before* attempting to place any Live order, `wallet_manager` **must** execute read-only API calls to the exchange to fetch:
            1.  Current available balance for the quote currency (e.g., USDT) and base currency (e.g., BTC).
            2.  Current available **margin balance** (if the trade intends to use leverage).
        *   **Validation:** Compare fetched balances/margin with the requirements calculated for the intended trade (cost + fees, required margin).
        *   **Action on Failure/Insufficiency:** If JIT checks are enabled and either the API call fails (after retries) or funds/margin are insufficient: **Abort the trade attempt immediately.** Log a CRITICAL error to `audit_trail` (`action_type=JIT_CHECK_FAILURE` or `JIT_CHECK_INSUFFICIENT_FUNDS`, `status=FAILURE`). Notify the user prominently via the UI dashboard.
        *   **Action if Disabled:** If `require_jit_checks: false`, proceed with trade attempt based on local state. Log a WARNING (`action_type=TRADE_ATTEMPT_NO_JIT_CHECK`, `status=WARNING`). The system must then gracefully handle potential order rejection by the exchange API later due to insufficient funds, log it, and trigger reconciliation.
        *   **Auditing:** Log the JIT check configuration (`details={'jit_enabled': ...}`), the attempt (`action_type=JIT_CHECK_ATTEMPT`), the outcome (`action_type=JIT_CHECK_SUCCESS`/`FAILURE`/`INSUFFICIENT_FUNDS`), and the balances returned by the API (optional, depends on sensitivity).
    *   **Position Sizing (Leverage Aware):** Calculated meticulously by `wallet_manager` based on:
        1.  `risk_per_trade_percent` (from active Risk Profile).
        2.  *Estimated* Current Portfolio Value (derived from `wallets_live` balances converted using latest market prices from `data_fetcher`; acknowledge estimation).
        3.  Stop-loss price provided by the strategy (crucial for risk calculation).
        4.  **If High Risk mode & Leverage active/configured:** Incorporate `leverage_per_asset` factor. Calculate `Required Margin`. Check against *JIT-fetched* Available Margin (if checks enabled). Adjust size down if margin is insufficient but available, or abort if margin is zero/negative.
    *   **Auditing:** Log all inputs to sizing calculation (`risk%`, `portfolio_value_est`, `SL_price`, `leverage_factor`, `available_margin_jit`) and the final `calculated_size` and `required_margin` to `audit_trail`.
    *   **Order Execution (Leverage Aware):** Use the exchange's execution API client. If leverage is used, ensure correct parameters (`leverage`, `marginType` etc.) are passed as per API documentation. Prioritize using exchange-native Stop-Loss parameters (`stopPrice`, OCO etc.) if strategy provided an SL and exchange API supports it within the order placement call.
    *   **Auditing:** Log the API call attempt (`action_type=TRADE_API_SUBMIT_ATTEMPT`), including sanitized parameters (mask keys, show asset, side, qty, type, leverage, SL price). Log the immediate API response summary (`action_type=TRADE_API_SUBMIT_RESPONSE`, `status=SUCCESS/FAILURE`, `details={'exchange_order_id': ..., 'api_response_code': ...}`). Update `trades_live` status initially to `SUBMITTED` or `REJECTED`.
    *   **Reconciliation Loop (Essential for Live Accuracy):**
        *   A background task scheduled by `main_controller` (e.g., every 1-5 minutes).
        *   Queries the exchange API for the status of all orders in `trades_live` that are in non-final states (`SUBMITTED`, `ACCEPTED`, `PARTIALLY_FILLED`).
        *   Queries current balances and margin status via read-only API.
        *   Compares API results with local state (`trades_live`, `wallets_live`).
        *   Updates local tables to reflect actual fills (quantity, average price, status -> `FILLED`/`CANCELED`), balances, and margin.
        *   Updates the `portfolio_risk_state` (current value, drawdown) based on reconciled data.
        *   **Auditing:** Log the start and end of each reconciliation cycle (`action_type=RECONCILIATION_START/END`). Log any discrepancies found and updates made (`action_type=RECONCILIATION_UPDATE`, `details={'table': 'trades_live', 'id': ..., 'old_status': ..., 'new_status': ...}`). This loop is vital for correcting state after failures or partial fills and for accurate drawdown tracking.

### **7. Strategy Engine (Risk Profile Aware Filter)**

*   **Instruction:** Define strategy execution, ensuring the `trading_engine` filters signals based on the active Risk Profile before further processing.

    *   **Signal Generation:** Strategy classes (inheriting `BaseStrategy`) receive market data and return a dictionary: `{'signal': 'BUY'/'SELL'/'HOLD', 'stop_loss': price (optional), 'confidence': float (optional)}`.
    *   **Risk Profile Filtering Logic (in `trading_engine`):** After a strategy generates a signal, but *before* calculating risk or proposing/executing a trade, the engine performs checks based on the **currently active Risk Profile** (read from `portfolio_risk_state` or system state):
        *   **If `Low` Risk:**
            *   Check if the generating strategy is allowed (e.g., based on optional `suitable_risk_profiles` metadata associated with the strategy class, or a configured list). If not allowed, discard signal. Log `AUDIT - SIGNAL_FILTERED (Reason=StrategyRiskMismatch, Profile=Low, Strategy={name})`.
            *   Potentially enforce stricter conditions (e.g., require higher signal confidence if provided by strategy, ignore signals during high market volatility metrics - requires volatility calculation).
        *   **If `Medium` Risk:**
            *   Allow strategies tagged 'Low' or 'Medium'. Apply standard signal validation.
        *   **If `High` Risk:**
            *   Allow all strategies by default (unless explicitly blacklisted). Focus shifts to per-trade risk calculation and portfolio limits.
    *   **Stop-Loss Enforcement:** If a profile requires a stop-loss (e.g., Medium/High config) but the strategy signal doesn't provide one, the engine might either discard the signal or calculate a default SL (e.g., based on ATR), depending on configuration (`require_stop_loss_from_strategy: true/false`). Log this check.
    *   **Auditing:** Log the signal generated (`action_type=SIGNAL_GENERATED`). Log the outcome of the risk profile filtering step (`action_type=SIGNAL_FILTER_PASS` or `SIGNAL_FILTER_REJECTED`, `details={'reason': ...}`).

### **8. Optimization (Risk Profile Aware, Adaptive, Controlled, Realistic)**

*   **Instruction:** Define the optimization process using external libraries, incorporating live feedback, guided by the target risk profile, allowing user supervision, and explicitly acknowledging limitations regarding leverage backtesting.

    *   **External Library Reliance:** The `strategy_optimizer` acts as an orchestrator, leveraging established backtesting libraries like `backtrader` or `vectorbt` for running the actual simulations. Configure the preferred library in `config.yaml`. This avoids reinventing a complex backtesting engine.
    *   **Adaptive Learning (Live Feedback Integration):**
        *   **Data Collection:** Periodically (e.g., daily), the optimizer queries `trades_live` and associated `audit_trail` entries to gather actual performance data for specific strategy/parameter combinations that have been active recently. Metrics calculated include: realized P&L, win rate, drawdown during live execution period.
        *   **Weighted Scoring:** When evaluating a strategy/parameter set during optimization:
            1.  Run backtest using the chosen library, obtaining metrics like Sharpe Ratio (`Backtest_Score`) and Max Drawdown (`Backtest_Drawdown`).
            2.  Retrieve recent live performance metrics (`Live_Score`, e.g., recent P&L or win rate). Handle cases with insufficient live data (assign neutral score or zero weight).
            3.  Calculate a `Final_Score = (1 - weight) * Backtest_Score + weight * Live_Score`, where `live_performance_feedback_weight` is a configurable value (0.0 to 1.0) in `config.yaml`. A weight of 0 disables live feedback.
        *   This allows the system to favor strategies that, while perhaps slightly suboptimal in long-term backtests, are performing well under *current* market conditions.
    *   **Risk Profile Aware Optimization:**
        *   **Target Profile:** When optimization is run (scheduled or manually triggered), it targets a specific Risk Profile (`Low`, `Medium`, `High`). This target profile dictates the constraints used.
        *   **Constraints:** The optimizer only considers strategy/parameter combinations whose backtested Maximum Drawdown (`Backtest_Drawdown`) is *less than* the `optimizer_max_strategy_drawdown` limit defined for the **target Risk Profile** in `config.yaml`.
        *   **Parameter Ranges:** Optimization parameter ranges (`strategies/strategy_library/config/{strategy_name}.yaml` or similar) might optionally be adjusted based on the target profile (e.g., allow wider ranges for High risk).
    *   **Leverage Backtest Limitation Acknowledgment:**
        *   **Core Issue:** Backtesting libraries typically cannot accurately model exchange-specific liquidation mechanics, funding rates, or cascading margin calls inherent in leveraged trading.
        *   **Mitigation/Approach:**
            1.  **Penalize Leverage in Backtest:** If optimizing for High Risk with leverage intended, the optimizer should ideally run backtests *without* leverage first. Strategies selected must demonstrate profitability even at 1x. Leverage is treated as an amplification factor applied later, not the source of edge. Alternatively, apply a significant penalty to the `Final_Score` if the backtest relied heavily on simulated leverage (if the library supports simulating it crudely).
            2.  **Documentation & UI:** Explicitly state in `README.md` and UI tooltips that backtesting results for leveraged strategies are indicative at best and carry high uncertainty.
    *   **User Control & Approval:**
        *   Optimization can be triggered manually via the UI, specifying the target Risk Profile.
        *   The `require_strategy_approval` flag in `config.yaml` determines the workflow:
            *   `false`: Optimizer runs, finds the best valid strategy based on `Final_Score` and constraints, updates the `strategies` table in the DB to `status='ACTIVE'`, logs the change, and the `trading_engine` picks it up.
            *   `true`: Optimizer runs, finds the best valid strategy, but sets its status to `status='PROPOSED'` in the `strategies` table. The UI then displays this proposal (comparing it to the currently active one) for the user to Approve/Reject. Approval changes status to `ACTIVE`. Rejection leaves the old strategy active (or potentially disables the asset if no valid strategy exists).
    *   **Auditing:** Log the start of optimization (`target_profile`), library used, parameters/strategies tested, backtest scores, live feedback scores used, final weighted scores, drawdown checks, whether leverage was considered/penalized, the proposed/assigned strategy, and any user approval action (`actor=USER`).

### **9. Correlation zu Leitwährungen (Optional Analysis)**

*   **Instruction:** Define this as an optional, supplementary feature, clearly separated from core trading logic and emphasizing risk awareness.

    *   **Configuration:** Enable/disable via a flag `enable_correlation_analysis: true/false` in `config.yaml`. Default should be `false`.
    *   **Implementation:** If enabled, a separate module (`analysis/correlation_engine.py`) runs periodically (e.g., hourly or daily). It fetches historical data for lead coins (BTC, ETH from config) and a list of low-cap coins (defined in config or dynamically queried).
    *   **Logic:** Identifies significant moves in lead coins (e.g., > +/- 2% in 1h) and measures the corresponding percentage change of low-cap coins in the same (or slightly delayed) window. Calculates `Efficiency Ratio = altcoin_delta / base_delta`. Stores individual event results (timestamp, base, alt, deltas, efficiency, price, volume) in a dedicated DB table (`correlation_results`).
    *   **Aggregation & Ranking:** Periodically aggregates results to calculate Avg. Efficiency, StdDev of Efficiency, Hit Count for each Alt/Base pair.
    *   **UI Display:** If enabled, results are shown in a dedicated tab/section on the dashboard. **Crucially, display includes:**
        *   Ranked list (e.g., Top 20 by Avg. Efficiency).
        *   Columns for Avg. Efficiency, **StdDev (Consistency)**, Hit Count.
        *   **Explicit Warning:** A clear text warning stating: "High efficiency often indicates extreme volatility and risk. This data is informational only and NOT a trade recommendation. DYOR."
    *   **Core Logic Integration:** By default, correlation results **do not** directly influence trade signals or strategy selection in the `trading_engine`. It remains a purely analytical tool for the user. (Advanced users could potentially configure strategies to *consider* correlation state, but this adds complexity and is not part of the baseline V6).
    *   **Auditing:** Log the start and completion of correlation analysis runs (`action_type=CORRELATION_ANALYSIS_RUN`, `status=SUCCESS/FAILURE`, `details={'assets_analyzed': ...}`).

### **10. Database Schema (V6 - Reflecting Refinements)**

*   **Instruction:** Provide the complete, optimized SQL schema for V6, including `audit_trail` with context, refined `strategies` and `portfolio_risk_state` tables, and reflecting simplified structures where applicable. Recommend ORM + Migrations.

*   **Technology:** SQLite recommended for default local use (simple, file-based). PostgreSQL as a robust alternative. **Strongly recommend SQLAlchemy ORM** for Python interaction and **Alembic** for managing schema migrations.

*   **Complete Schema (`database/schema_v6.sql`):**

    ```sql
    -- Enable Write-Ahead Logging for better concurrency and robustness (SQLite specific)
    PRAGMA journal_mode=WAL;
    -- Enforce foreign key constraints (SQLite specific)
    PRAGMA foreign_keys = ON;

    -- Audit Trail: THE central, immutable record keeper
    CREATE TABLE IF NOT EXISTS audit_trail (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        mode TEXT NOT NULL CHECK(mode IN ('TEST', 'LIVE', 'SYSTEM')), -- Operating context
        actor TEXT NOT NULL DEFAULT 'SYSTEM', -- 'USER' for user-initiated actions
        action_type TEXT NOT NULL, -- Standardized verb describing the action (e.g., SYSTEM_START, CONFIG_LOADED, DATA_FETCH_SUCCESS, SIGNAL_GENERATED, RISK_CHECK_PASS, JIT_CHECK_ATTEMPT, TRADE_API_SUBMIT_ATTEMPT, RECONCILIATION_UPDATE, LEVERAGE_ENABLED, EMERGENCY_HALT_TRIGGERED)
        status TEXT NOT NULL CHECK(status IN ('SUCCESS', 'FAILURE', 'PENDING', 'INFO', 'WARNING', 'CRITICAL', 'APPROVED', 'REJECTED')), -- Outcome or state
        risk_profile TEXT, -- The active risk profile ('Low', 'Medium', 'High') at the time of the action, if applicable
        details TEXT, -- JSON blob containing relevant contextual data (parameters, results, error messages, user confirmation details, file paths etc.)
        related_entity_type TEXT, -- Optional: Type of related entity (e.g., 'TradeLive', 'Strategy', 'Asset')
        related_entity_id INTEGER -- Optional: ID of the related entity
    );
    CREATE INDEX IF NOT EXISTS idx_audit_trail_timestamp ON audit_trail (timestamp DESC); -- Index for recent logs
    CREATE INDEX IF NOT EXISTS idx_audit_trail_mode_type_status ON audit_trail (mode, action_type, status);
    CREATE INDEX IF NOT EXISTS idx_audit_trail_actor ON audit_trail (actor);
    CREATE INDEX IF NOT EXISTS idx_audit_trail_risk_profile ON audit_trail (risk_profile);
    CREATE INDEX IF NOT EXISTS idx_audit_trail_related ON audit_trail (related_entity_type, related_entity_id);
    -- Add DB-level triggers to prevent UPDATE/DELETE if possible and desired for extra safety.

    -- Test Wallet State (Bot's view of simulated balances)
    CREATE TABLE IF NOT EXISTS wallets_test (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      asset TEXT NOT NULL UNIQUE, -- e.g., 'BTC', 'USDT'
      balance REAL NOT NULL DEFAULT 0.0 CHECK(balance >= 0),
      last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- When bot last modified this record
    );
    -- Seed initial test capital (e.g., via config on first run or migration)
    -- INSERT OR IGNORE INTO wallets_test (asset, balance) VALUES ('USDT', 10000.0);

    -- Test Trades (Record of simulated executions)
    CREATE TABLE IF NOT EXISTS trades_test (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Time of simulated execution
      asset TEXT NOT NULL, -- Asset bought/sold (e.g., BTC)
      base_currency TEXT NOT NULL, -- Currency used (e.g., USDT)
      action TEXT NOT NULL CHECK(action IN ('BUY', 'SELL')),
      quantity REAL NOT NULL CHECK(quantity > 0),
      simulated_price REAL NOT NULL CHECK(simulated_price > 0), -- Execution price after simulated slippage
      simulated_fee REAL NOT NULL DEFAULT 0.0 CHECK(simulated_fee >= 0),
      fee_currency TEXT, -- Currency the fee was paid in
      strategy TEXT, -- Strategy that generated the signal
      audit_ref_id INTEGER -- Optional reference to the initiating audit_trail entry ID
      -- FOREIGN KEY (audit_ref_id) REFERENCES audit_trail(id) -- Optional FK constraint
    );
    CREATE INDEX IF NOT EXISTS idx_trades_test_asset_time ON trades_test (asset, timestamp);

    -- Secure API Key Storage
    CREATE TABLE IF NOT EXISTS api_keys_encrypted (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key_ref TEXT NOT NULL UNIQUE, -- User-defined name (e.g., 'binance_read_key')
        exchange TEXT NOT NULL, -- e.g., 'Binance'
        permissions TEXT, -- e.g., 'ReadOnly, Trade' (Informational)
        encrypted_key BLOB NOT NULL, -- AES-GCM encrypted key data (key + nonce + tag)
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Live Wallet State (Bot's local view, updated by actions & reconciliation)
    CREATE TABLE IF NOT EXISTS wallets_live (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      exchange TEXT NOT NULL,
      asset TEXT NOT NULL,
      balance REAL NOT NULL, -- Balance known by the bot after its last action or successful reconciliation
      api_key_ref TEXT, -- Informational link to the key used (if applicable)
      last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- When bot last modified this record
      last_reconciliation_ts TIMESTAMP, -- Timestamp of the last successful reconciliation affecting this asset
      UNIQUE(exchange, asset)
      -- FOREIGN KEY (api_key_ref) REFERENCES api_keys_encrypted(key_ref) -- Optional FK
    );

    -- Live Trades (Record of bot's attempted/executed trades & their reconciled status)
    CREATE TABLE IF NOT EXISTS trades_live (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Time bot initiated the action
      exchange TEXT NOT NULL,
      exchange_order_id TEXT UNIQUE, -- Exchange's ID, can be NULL initially or if submission failed
      asset TEXT NOT NULL, base_currency TEXT NOT NULL, action TEXT NOT NULL,
      order_type TEXT NOT NULL, -- e.g., MARKET, LIMIT, STOP_LIMIT
      quantity_requested REAL NOT NULL CHECK(quantity_requested > 0),
      quantity_filled REAL DEFAULT 0.0 CHECK(quantity_filled >= 0),
      limit_price REAL, -- Requested price for LIMIT orders
      avg_fill_price REAL, -- Average price if filled/partially filled (from reconciliation)
      stop_loss_price REAL, -- Stop loss price requested with the order (if applicable)
      leverage_used REAL DEFAULT 1.0, -- Leverage applied for this specific trade
      status TEXT NOT NULL DEFAULT 'PENDING' CHECK(status IN ('PENDING', 'SUBMITTED', 'REJECTED', 'ACCEPTED', 'PARTIALLY_FILLED', 'FILLED', 'CANCELED', 'ERROR', 'RECONCILED_UNKNOWN')), -- Status reflecting bot action and reconciliation outcome
      strategy TEXT,
      last_reconciliation_ts TIMESTAMP, -- When reconciliation last updated this order's status/fills
      audit_ref_id INTEGER -- Optional reference to the initiating audit_trail entry ID
      -- FOREIGN KEY (audit_ref_id) REFERENCES audit_trail(id) -- Optional FK
    );
    CREATE INDEX IF NOT EXISTS idx_trades_live_status ON trades_live (status, last_reconciliation_ts);
    CREATE INDEX IF NOT EXISTS idx_trades_live_exchange_order ON trades_live (exchange, exchange_order_id);
    CREATE INDEX IF NOT EXISTS idx_trades_live_asset_time ON trades_live (asset, timestamp);

    -- Strategies (Stores the active or proposed strategy per asset)
    CREATE TABLE IF NOT EXISTS strategies (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      asset TEXT NOT NULL, -- e.g., 'BTC-USDT'
      strategy_type TEXT NOT NULL, -- Name of the strategy class
      parameters TEXT NOT NULL, -- JSON string of the selected parameters
      status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE', 'PROPOSED')), -- ACTIVE is used, PROPOSED needs user approval
      -- Performance/Risk metrics from the optimization run that selected/proposed this:
      primary_score REAL, -- e.g., Weighted Sharpe/Sortino
      backtest_max_drawdown REAL, -- Max drawdown observed in backtest
      live_feedback_score REAL, -- Score derived from recent live performance
      performance_details TEXT, -- JSON blob of all metrics from optimizer
      last_optimized_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      UNIQUE(asset, status) -- Ensures only one ACTIVE and one PROPOSED per asset
    );
    CREATE INDEX IF NOT EXISTS idx_strategies_asset_status ON strategies (asset, status);

    -- Portfolio Risk State (Singleton table tracking overall risk)
    CREATE TABLE IF NOT EXISTS portfolio_risk_state (
        id INTEGER PRIMARY KEY CHECK (id = 1), -- Enforce single row
        current_risk_profile TEXT NOT NULL DEFAULT 'Low', -- Active profile ('Low', 'Medium', 'High')
        -- Portfolio Value Tracking
        current_portfolio_value_usd REAL, -- Estimated based on local state + market prices
        peak_portfolio_value_usd REAL, -- Highest value recorded since last reset/start
        -- Drawdown Tracking
        current_drawdown_percent REAL, -- (peak - current) / peak
        current_max_drawdown_limit REAL, -- The limit % for the active profile (copied from config)
        -- Halt Status
        is_trading_halted BOOLEAN DEFAULT FALSE, -- Global halt flag (manual or emergency)
        is_emergency_stop_active BOOLEAN DEFAULT FALSE, -- Specifically triggered by drawdown limit breach
        emergency_stop_triggered_at TIMESTAMP,
        halt_reason TEXT, -- 'MANUAL', 'EMERGENCY_DRAWDOWN', 'API_FAILURE', 'MANUAL_RESET' etc.
        last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    -- Initialize the singleton row on first setup/migration
    -- INSERT OR IGNORE INTO portfolio_risk_state (id, current_risk_profile, peak_portfolio_value_usd, current_portfolio_value_usd, current_max_drawdown_limit) VALUES (1, 'Low', 0, 0, 0.10); -- Example initial values

    -- System Configuration (Optional table for dynamic system settings if needed beyond config file)
    -- CREATE TABLE IF NOT EXISTS system_config ( key TEXT PRIMARY KEY, value TEXT, last_updated TIMESTAMP );

    -- Correlation Results (Optional table, if feature enabled)
    CREATE TABLE IF NOT EXISTS correlation_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TIMESTAMP NOT NULL, base_coin TEXT NOT NULL, altcoin TEXT NOT NULL,
        base_delta REAL NOT NULL, altcoin_delta REAL NOT NULL, efficiency_score REAL,
        altcoin_price REAL, altcoin_volume_24h REAL
    );
    CREATE INDEX IF NOT EXISTS idx_correlation_results_time_base_alt ON correlation_results (timestamp, base_coin, altcoin);

    ```

### **11. UI/UX & Dashboards (Hierarchical, Clear Warnings)**

*   **Instruction:** Specify the single-page dashboard design prioritizing clarity, information hierarchy, prominent status indicators and risk warnings, and intuitive controls with necessary confirmations.

    *   **Technology:** Recommend Dash or Streamlit for ease of development in Python. Use a component-based approach for reusability.
    *   **Layout Principle:** Single-page application with a persistent header/status bar and distinct tabs or expandable sections for different information categories. Employ progressive disclosure – show essential info first, allow drilling down for details.
    *   **Persistent Status Bar (Always Visible):**
        *   **Critical Info:** Displays the most vital real-time information with clear visual cues (color coding, icons).
        *   **Elements:**
            *   `Current Operational Mode:` (Observe / Semi-Auto / Full-Auto) - Clearly labeled.
            *   `Current Risk Profile:` (Low / Medium / High) - Color coded (e.g., Green/Yellow/Red).
            *   `Leverage Status:` (Inactive / ACTIVE) - **Blinking Red "LEVERAGE ACTIVE"** if enabled and configured for any asset.
            *   `Estimated Portfolio Value:` (USDT/USD) - Updated regularly based on `portfolio_risk_state`.
            *   `Current Drawdown:` (X.XX %) - Updated regularly, turns Red if approaching limit.
            *   `System Halt Status:` (Running / HALTED) - **Bright Red "HALTED"** if `is_trading_halted` is true. Include `halt_reason`.
            *   `Emergency Stop Status:` (Inactive / ACTIVE) - **Bright Red "EMERGENCY STOPPED"** if `is_emergency_stop_active` is true.
    *   **Main Content Area (Tabs or Sections):**
        *   **`Overview` Tab:**
            *   System Status Summary: Uptime, Last Fetch/Optimization/Backup times.
            *   Portfolio Value Chart: Historical trend (Test/Live selectable).
            *   Key Asset Balances: Table showing balances from `wallets_test`/`wallets_live`.
            *   Recent **Live** Trades Summary: Small table of last 5-10 live trades (link to full view).
            *   Recent **Critical Audit Logs:** Display recent 'FAILURE' or 'CRITICAL' status entries from `audit_trail`.
            *   **Emergency Halt Info:** Clearly display the `max_portfolio_drawdown_limit` for the current profile vs the `current_drawdown_percent`. Display button to "Clear Emergency Halt" (requires PIN/confirmation) if active.
            *   **Global Controls:** Buttons for "HALT ALL TRADING" / "RESUME TRADING" (require confirmation, logs `actor=USER`). Button for "PANIC - Attempt Market Close All & Halt" (requires **extreme** confirmation, uses configured `emergency_halt_action` logic if set to close, otherwise cancels/halts).
        *   **`Performance & Trades` Tab:**
            *   Detailed P&L Chart: Selectable time range, Test/Live mode.
            *   Performance Metrics Table: Key metrics (Sharpe, Sortino, Max Drawdown, Win Rate, P&L - calculated from trade history) for selected mode/period.
            *   **Filterable Trade History Table:** The core view for analyzing trades.
                *   *Filters:* Mode (Test/Live), Date Range, Asset Pair, Strategy, Action (Buy/Sell), Status (Filled, Canceled etc.).
                *   *Columns:* Timestamp, Mode, Asset, Action, Qty Requested, Qty Filled, Avg Fill Price, Leverage, Strategy, Status, Realized P&L (calculated). Allow sorting.
        *   **`Strategies & Risk` Tab:**
            *   **Configuration Controls:**
                *   Dropdown/Buttons to **Select Operational Mode** (triggers confirmation modal).
                *   Dropdown/Buttons to **Select Risk Profile** (triggers confirmation modal with risk explanation).
                *   **Leverage Control Section (Only visible if `allow_leverage: true` in config):** Toggle Switch to Enable/Disable Leverage Usage (triggers multi-stage confirmation modal with warnings/PIN). Display current `leverage_per_asset` settings.
            *   **Active/Proposed Strategies Table:** List monitored assets. Show Status ('ACTIVE'/'PROPOSED'), Strategy Type, Parameters, Key Metrics (Score, Drawdown from last optimization). If 'PROPOSED', include Approve/Reject buttons (triggers confirmation).
            *   **Optimization Control:** Button to "Trigger Manual Optimization". Dropdown to select target Risk Profile for the run. Display status/progress of running optimization.
            *   **Open Positions Table (Live):** Derived from `trades_live` (status `PARTIALLY_FILLED` or `FILLED` without a corresponding closing trade) + current market data. Columns: Asset, Side (Long/Short), Quantity, Entry Price, Current Price, **Leverage**, **Est. Margin Used**, **Unrealized P&L (%)**, **Stop-Loss Level** (if set).
            *   **Exposure Chart:** Pie chart showing portfolio allocation by asset value (Live).
            *   Correlation Analysis Results (Optional Section, if enabled): Display ranked table with risk warnings.
        *   **`Trade Proposals` Tab/Section (Only relevant in Semi-Auto Mode):**
            *   Displays pending trade proposals awaiting user action.
            *   Each proposal shown as a card/row with: Asset, Action, Size, Entry, SL, Risk%, Leverage, Signal Source. Includes Approve/Reject buttons (trigger confirmation).
        *   **`Audit Trail` Tab:**
            *   **Filterable View** of the `audit_trail` table.
            *   *Key Filters:* Mode (Test/Live/System), Actor (System/User), Date Range, Action Type (dropdown with common types), Status (Success/Failure/etc.), Risk Profile. Free text search in `details`.
            *   Pagination for performance.
    *   **Confirmation Modals ("Save Stages"):** Use modal dialogs for all critical actions (mode changes, risk changes, leverage toggle, trade/strategy approvals, halt commands). Modals must clearly state the action, its consequences/risks, and require an explicit confirmation step (button click, potentially PIN entry or typing confirmation phrase).

### **12. Inter-module Communication (Internal Async Queue)**

*   **Instruction:** Utilize a simple and reliable internal asynchronous event queue for decoupling core components running within the main process.

    *   **Technology:** Python's built-in `asyncio.Queue` is recommended. Instantiate the queue(s) in `main_controller.py` and pass references to modules that need to publish or subscribe.
    *   **Purpose:** Decouple producers (e.g., `data_fetcher` publishing 'DATA_READY', `user_command_handler` publishing 'MODE_CHANGE_REQUESTED') from consumers (e.g., `trading_engine` consuming 'DATA_READY', `main_controller` consuming 'MODE_CHANGE_REQUESTED'). Allows components to operate asynchronously without direct dependencies.
    *   **Event Structure:** Use standardized JSON-like Python dictionaries for events:
        ```python
        event = {
            "event_type": "DATA_READY",
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "source_module": "data_fetcher",
            "payload": { "asset": "BTC-USDT", "new_data_count": 100 }
        }
        # Other examples: TRADE_PROPOSAL_READY, TRADE_PROPOSAL_RESOLVED, STRATEGY_PROPOSAL_READY,
        # STRATEGY_ASSIGNED, RISK_PROFILE_CHANGED, LEVERAGE_STATUS_CHANGED, EMERGENCY_HALT_TRIGGERED
        ```
    *   **Workflow:** Modules `put` events onto the queue. The main event loop in `main_controller` (or dedicated consumer tasks) `get` events from the queue and dispatch them to the appropriate handler function/method in the relevant module based on `event_type`.
    *   **Error Handling:** Implement error handling within event consumers. If processing fails, log the error to `audit_trail`. Consider basic retry logic for transient issues or a mechanism to handle persistent failures (e.g., log critical error, halt related processing). Avoid letting queue processing block the main loop indefinitely.
    *   **Auditing:** Log the publication of significant events (`action_type=EVENT_PUBLISHED`, `details={'event_type': ...}`) and the start/completion/failure of handling critical events (`action_type=EVENT_HANDLER_START/END`, `status=SUCCESS/FAILURE`) to the `audit_trail` for debugging and tracing data flow.

### **13. Error Handling, Logging & Recovery (Focus on Reconciliation & Clarity)**

*   **Instruction:** Detail comprehensive error handling, structured logging to both files and the central audit trail (including actor/risk context), robust state reconciliation for live operations, and clear recovery procedures.

    *   **Error Handling Philosophy:** Anticipate failures proactively. Wrap potentially failing operations (API calls, file I/O, data parsing, DB operations, complex calculations) in specific `try...except` blocks. Log errors with detailed context. Avoid catching broad `Exception` unless for cleanup/shutdown.
    *   **Logging Strategy:**
        *   **File Logs (`logs/`):** Use for detailed debugging information. Structured JSON format. Separate files for Test/Live/System. Use appropriate log levels (DEBUG, INFO, WARNING, ERROR, CRITICAL). Configurable log level via `config.yaml`. Ensure sensitive data is NEVER logged here.
        *   **Audit Trail DB (`audit_trail`):** The **immutable primary record** for *all* significant system events, user actions, status changes, and errors. Log informational events (SUCCESS, INFO, WARNING) and especially all failures (FAILURE, CRITICAL). Include `mode`, `actor`, `risk_profile`, and detailed JSON context in the `details` field. Errors logged here should clearly state the module, function, and provide traceback information (or a summary) in the details.
    *   **Specific Error Handling Examples:**
        *   *API Call Failure (Execution/JIT Check):* Retry with exponential backoff (respect Retry-After). If still failing, log CRITICAL error to audit trail, abort the current action (e.g., trade), potentially trigger a partial system halt (e.g., disable trading for that exchange/asset pair), notify user via UI.
        *   *Reconciliation Failure (API Error):* Log WARNING/ERROR to audit trail, continue reconciliation attempt for other assets/orders, retry failed API calls later. Persistent failure requires user notification.
        *   *Strategy Logic Error:* Catch exception during `generate_signal`. Log ERROR to audit trail. Optionally, disable the faulty strategy automatically (`strategies` table status?) and notify the user. Prevent repeated crashes.
        *   *Database Error:* Use transactions. Handle transient errors (e.g., deadlock) with retries. Log persistent errors. Monitor disk space.
    *   **Live State Reconciliation (Crucial):**
        *   **Necessity:** Essential because the bot's local state (`wallets_live`, `trades_live`) can diverge from the actual exchange state due to network issues, API errors, partial fills, manual interventions by the user outside the bot, or system crashes. Accurate state is vital for risk management (drawdown calculation, position sizing).
        *   **Mechanism:** A background task scheduled by `main_controller` (e.g., every 1-5 minutes, configurable).
        *   **Actions:**
            1.  Query exchange API (read-only key) for status of all orders currently marked as non-final (`PENDING`, `SUBMITTED`, `ACCEPTED`, `PARTIALLY_FILLED`) in the local `trades_live` table.
            2.  Query exchange API for current balances of all relevant assets and current available margin balance.
            3.  Compare API results with local DB state.
            4.  **Update `trades_live`:** Change status, update `quantity_filled`, `avg_fill_price`, `last_reconciliation_ts` based on actual exchange data. Mark orders as `RECONCILED_UNKNOWN` if they exist locally but not on the exchange (potential issue).
            5.  **Update `wallets_live`:** Adjust balances based on filled trades identified during reconciliation and direct balance query from the exchange. Update `last_reconciliation_ts`.
            6.  **Update `portfolio_risk_state`:** Recalculate `current_portfolio_value_usd` and `current_drawdown_percent` based on the reconciled wallet balances and current market prices.
        *   **Auditing:** Log the start/end of each reconciliation cycle. Log EVERY discrepancy found and EVERY update made to local tables (`action_type=RECONCILIATION_UPDATE`, `details={'table': ..., 'id': ..., 'field': ..., 'old_value': ..., 'new_value': ...}`). Log errors during reconciliation API calls.
    *   **Recovery Procedures:**
        *   **Automatic Startup Check:** On start, run consistency checks (DB vs audit trail). Initiate reconciliation immediately for pending live trades.
        *   **Manual Recovery (Guided by Audit Trail):** If automatic recovery fails or state seems corrupt, the detailed `audit_trail` (exported regularly) is the primary tool for diagnosing what happened. The `README.md` should provide guidance on interpreting the audit trail and potentially making manual DB corrections or API checks.
        *   **Backup Restore:** Use the automated backups (Section 14) as a last resort for catastrophic data loss. `README.md` must clearly document the restore process (stop bot, restore DB file, restore config files, restart bot, carefully check state).

### **14. Automated Backups & Exports (Simple & Robust)**

*   **Instruction:** Define simple, reliable, and automated procedures for backing up critical system state and exporting key data, ensuring actions are audited.

    *   **Backup Script/Function (`operations/run_backup.py`):**
        *   **Trigger:** Scheduled periodically (e.g., daily, or configurable `backup_frequency_hours`) by the `main_controller` using a scheduler library like `APScheduler`.
        *   **Mechanism:**
            1.  Determine the path to the live SQLite database file (from `config.yaml`).
            2.  Use the SQLite `.backup` command-line feature or equivalent Python binding (`sqlite3.Connection.backup`) to create a consistent snapshot of the database file to a temporary location, even while the database is in use (leveraging WAL helps).
            3.  Create a timestamped archive file (e.g., `backup_YYYYMMDD_HHMMSS.zip` or `.tar.gz`).
            4.  Add the database snapshot file to the archive.
            5.  Add the current configuration files (`config.yaml`, `secrets.yaml.enc`) to the archive.
            6.  Save the complete archive to the `backup_path` specified in `config.yaml`.
        *   **Retention:** Implement simple rotation. After a successful backup, check the number of existing backup files in the target directory. Delete the oldest backup file(s) if the count exceeds `backup_retention_count` (configured in `config.yaml`).
        *   **Error Handling:** Wrap the backup process in `try...except`. Log any errors during backup creation or cleanup to the `audit_trail` (`action_type=BACKUP_RUN`, `status=FAILURE`).
        *   **Auditing:** Log the start (`action_type=BACKUP_RUN`, `status=PENDING`), successful completion (`status=SUCCESS`, `details={'file_path': ..., 'size_bytes': ...}`), and any failures of the backup process to the `audit_trail` with `mode='SYSTEM'`.
    *   **Export Script/Function (`operations/run_export.py`):**
        *   **Trigger:** Scheduled periodically (e.g., daily at a specific time) by the `main_controller`.
        *   **Purpose:** Create human-readable extracts of key data for external analysis, archiving, or compliance.
        *   **Mechanism:**
            1.  Identify tables to export (list in `config.yaml`, e.g., `export_data_tables: ['audit_trail', 'trades_live', 'trades_test']`).
            2.  For each table:
                *   Query the database to retrieve the data (potentially filtering `audit_trail` by date range or `mode` if needed, based on config).
                *   Open a timestamped CSV file (e.g., `export_audit_trail_YYYYMMDD.csv`) in the `export_path` (from config).
                *   Use Python's standard `csv` module (`csv.writer`) to write the data row by row, including a header row. Handle potential large data volumes by processing in chunks if necessary. JSON Lines (`.jsonl`) format is an alternative if preferred.
        *   **Error Handling:** Wrap export process in `try...except`. Log errors to `audit_trail` (`action_type=EXPORT_RUN`, `status=FAILURE`).
        *   **Auditing:** Log the start (`action_type=EXPORT_RUN`, `status=PENDING`), successful completion (`status=SUCCESS`, `details={'exported_files': [...]}`), and any failures to the `audit_trail` with `mode='SYSTEM'`.

### **15. Setup & Configuration (Clear Risk & Operational Settings)**

*   **Instruction:** Specify requirements for an easy setup process and a clear, well-documented configuration file, paying special attention to explaining risk profiles, operational modes, leverage settings, JIT check toggles, Emergency Halt behavior, and approval flags.

    *   **Dependencies:** Provide a `requirements.txt` file with pinned versions of all necessary Python libraries (e.g., `pandas`, `requests`, `beautifulsoup4`, `sqlalchemy`, `alembic`, `pyyaml`, `pydantic`, `cryptography`, `bcrypt`, `apscheduler`, `plotly-dash` or `streamlit`, `pandas-ta`, `backtrader` or `vectorbt`, `python-binance` or other exchange clients).
    *   **Configuration File (`config.yaml`):** Use YAML for readability. Provide a heavily commented `config.example.yaml` file. Structure should be logical:
        ```yaml
        system:
          operational_mode: Observe # Observe | Semi-Automatic | Fully-Automatic (Default on first setup)
          require_strategy_approval: true # Does optimizer need user approval?
          require_jit_checks: true # Perform JIT balance/margin check before live trades?
          emergency_halt_action: HALT_ONLY # HALT_ONLY | CANCEL_ORDERS_AND_HALT | MARKET_CLOSE_ALL_AND_HALT (Requires extra ack)
          live_performance_feedback_weight: 0.2 # 0.0 to 1.0 - Weight for live results in optimizer score

        risk_profiles:
          Low:
            risk_per_trade_percent: 0.5
            max_portfolio_drawdown_limit: 0.10 # 10%
            optimizer_max_strategy_drawdown: 0.15
            # allowed_strategy_tags: ['LowRisk'] # Optional
          Medium:
            risk_per_trade_percent: 1.0
            max_portfolio_drawdown_limit: 0.20 # 20%
            optimizer_max_strategy_drawdown: 0.30
            # allowed_strategy_tags: ['LowRisk', 'MediumRisk'] # Optional
          High:
            risk_per_trade_percent: 2.0 # Requires warning/ack if > X%
            max_portfolio_drawdown_limit: 0.35 # 35% - Requires warning/ack if > Y%
            optimizer_max_strategy_drawdown: 0.50
            # allowed_strategy_tags: ['*'] # Optional - Allow all

        leverage: # Only relevant for High Risk mode
          allow_leverage: false # Master switch, requires UI multi-stage activation to use if true
          require_multi_stage_leverage_activation: true # Enforce strict UI confirmation
          # Leverage multiplier PER ASSET pair (if supported by exchange/client)
          leverage_per_asset:
            # Example:
            # BTC-USDT: 3
            # ETH-USDT: 5

        data_pipeline:
          # ... data sources, cache duration, api keys refs ...
          api_key_ref_read: "binance_read_key" # Reference to key in secrets file
          api_key_ref_trade: "binance_trade_key"

        database:
          path: "database/trading_system.db"

        logging:
          log_level: INFO # DEBUG | INFO | WARNING | ERROR | CRITICAL
          log_file_system: "logs/system.log"
          log_file_test: "logs/test.log"
          log_file_live: "logs/live.log"

        operations:
          backup_enabled: true
          backup_frequency_hours: 24
          backup_path: "backups/"
          backup_retention_count: 7
          export_enabled: true
          export_frequency_days: 1
          export_path: "exports/"
          export_data_tables: ["audit_trail", "trades_live"]

        # strategy_optimizer: # Optional section for optimizer specific params
        #   backtesting_library: "vectorbt" # backtrader | vectorbt

        # assets_to_monitor: ["BTC-USDT", "ETH-USDT"] # List of pairs
        ```
    *   **Secrets File (`secrets.yaml.enc`):** Store the AES-encrypted API keys and the bcrypt hash of the Master PIN. Provide instructions on how to generate this file securely (e.g., using a provided utility script).
    *   **Setup Script (Optional but Recommended):** A `setup.sh` or `Makefile` to:
        1.  Create Python virtual environment.
        2.  Install dependencies from `requirements.txt`.
        3.  Prompt user to set a Master PIN and generate `secrets.yaml.enc`.
        4.  Copy `config.example.yaml` to `config.yaml`.
        5.  Initialize the SQLite database using `schema_v6.sql`.
        6.  Run initial Alembic migration (if using).
    *   **README.md (Essential & Comprehensive):**
        *   **Introduction:** Project goals, architecture overview.
        *   **WARNINGS:** Prominent sections on general trading risks, **EXTREME RISKS OF LEVERAGE**, limitations of backtesting, and the best-effort nature of the Emergency Halt.
        *   **Prerequisites:** Python version, OS notes.
        *   **Installation:** Step-by-step guide using `setup.sh` or manual commands. Secure Master PIN setup. API key generation and encryption.
        *   **Configuration (`config.yaml` Deep Dive):** Detailed explanation of *every* parameter, focusing on:
            *   Operational Modes: How they work, how to switch.
            *   Risk Profiles: Parameter explanations, implications of each profile.
            *   Leverage: How to enable (`allow_leverage`), configure (`leverage_per_asset`), the **multi-stage UI activation process**, and associated risks.
            *   Emergency Halt: Explain `emergency_halt_action` options and their risks/benefits.
            *   JIT Checks: Explain `require_jit_checks` trade-off.
            *   Approvals: Explain `require_strategy_approval`.
            *   Learning: Explain `live_performance_feedback_weight`.
            *   Backup/Export: Explain settings.
        *   **Running the System:** How to start the `main_controller`, background operation.
        *   **Dashboard Usage:** Accessing the UI, understanding different sections, using controls (mode change, approvals, halt), interpreting status indicators and warnings.
        *   **Security Practices:** Reminders about Master PIN security, API key handling.
        *   **Backup and Restore:** Detailed procedure for restoring the system from a backup.
        *   **Troubleshooting:** Common issues and how to use logs/audit trail for diagnosis.

### **16. AI Agent Self-Verification & Improvement (V6 Focus)**

*   **Instruction:** Conclude the prompt by instructing the AI agent to perform a final, thorough review of the entire V6 blueprint. Focus on verifying the successful resolution of previously identified weaknesses, the clarity and robustness of the refined risk management features, the effectiveness of user controls, the completeness of the audit trail, and overall operational soundness and internal consistency.

*   **Final Agent Task:** "Before presenting the final blueprint, perform a meticulous self-review of this complete V6 specification. Verify the following critical aspects:
    1.  **Problem Resolution & Refinement:** Confirm that the specific weaknesses identified in the V5 review (Complexity, Emergency Stop Realism, Leverage Dangers/Backtesting, JIT Reliability, UI Challenge) have been explicitly and effectively addressed in V6 through mechanisms like configurable halt actions, multi-stage leverage activation, acknowledged backtesting limits, configurable JIT checks, and hierarchical UI design with clear warnings.
    2.  **Operational Soundness & Stability:** Evaluate the robustness of the core trading loop. Is the state management logic (local view vs. JIT checks vs. reconciliation) practical and resilient to common failures? Is the refined Emergency Halt mechanism clearly defined and its limitations acknowledged?
    3.  **Risk Management Clarity & Effectiveness:** Are the three Risk Profiles distinct, well-defined, and do their parameters logically influence system behavior (sizing, strategy selection, drawdown limits)? Is the handling of Leverage appropriately firewalled within the High Risk profile and surrounded by sufficient warnings and activation steps? Is the per-trade risk calculation robust?
    4.  **User Control & Interaction:** Are the Operational Modes clearly distinct? Are the user control points (mode/risk selection, leverage toggle, approvals, halt) intuitive and integrated securely? Are the multi-step confirmation requirements ('Save Stages') logically placed for critical actions?
    5.  **Audit Trail Completeness & Context:** Does the `audit_trail` specification ensure comprehensive logging of all system actions, user interactions, mode/risk changes, leverage usage, confirmations, reconciliation actions, errors, and operational tasks? Is the inclusion of `actor` and `risk_profile` context consistently applied?
    6.  **Maintained Core Goals:** Verify that V6 successfully maintains the core requirements established earlier (Security, Adaptivity, Local Operation, Test/Live Separation, Auditability) despite the refinements aimed at reducing complexity and enhancing operational safety.
    7.  **Internal Consistency & Clarity:** Check the entire document for internal consistency in terminology, module responsibilities, data flow, and database schema definitions. Is the language precise? Are explanations clear and unambiguous? Is the blueprint sufficiently detailed ("ultra-detailed") for implementation?
    8.  **Self-Correction:** Based on this review, identify any remaining logical gaps, ambiguities, potential edge-case failures, or areas where clarity could be improved *within the V6 specification*. Refine the blueprint text directly to address these findings, ensuring the final output represents the most robust, clear, and internally consistent design possible for this version."

---

**END OF COMPLETE, SELF-CONTAINED AI AGENT PROMPT (V6 - Fully Expanded)**