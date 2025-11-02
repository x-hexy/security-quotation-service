-- Security Guard Quotation Service Schema
-- Compatible with A5:SQL Mk-2 (standard SQL, PK/FK/index definitions)
-- Adjust data types to your RDB (PostgreSQL/MySQL/SQL Server) after import.

------------------------------------------------------------
-- 1. customer
------------------------------------------------------------
CREATE TABLE customer (
    customer_id         VARCHAR(36) PRIMARY KEY,
    customer_name       VARCHAR(255) NOT NULL,
    customer_type       VARCHAR(50) NOT NULL,
    billing_address     TEXT,
    contact_person_name VARCHAR(255),
    contact_phone       VARCHAR(50),
    contact_email       VARCHAR(255),
    notes               TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP NOT NULL
);

CREATE INDEX idx_customer_name ON customer(customer_name);
CREATE INDEX idx_customer_active ON customer(is_active);

------------------------------------------------------------
-- 2. site
------------------------------------------------------------
CREATE TABLE site (
    site_id             VARCHAR(36) PRIMARY KEY,
    customer_id         VARCHAR(36) NOT NULL,
    site_name           VARCHAR(255) NOT NULL,
    address             TEXT,
    site_type           VARCHAR(50),
    normal_operating_hours TEXT,
    risk_level_baseline VARCHAR(50),
    access_rules_summary TEXT,
    notes               TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP NOT NULL,
    CONSTRAINT fk_site_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE INDEX idx_site_customer ON site(customer_id);
CREATE INDEX idx_site_name ON site(site_name);

------------------------------------------------------------
-- 3. request
------------------------------------------------------------
CREATE TABLE request (
    request_id          VARCHAR(36) PRIMARY KEY,
    site_id             VARCHAR(36) NOT NULL,
    customer_id         VARCHAR(36) NOT NULL,
    request_title       VARCHAR(255) NOT NULL,
    description         TEXT,
    start_datetime      TIMESTAMP NOT NULL,
    end_datetime        TIMESTAMP NOT NULL,
    expected_crowd_size INTEGER,
    request_status      VARCHAR(50) NOT NULL,
    location_details    TEXT,
    special_requirements_summary TEXT,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP NOT NULL,
    CONSTRAINT fk_request_site
        FOREIGN KEY (site_id) REFERENCES site(site_id),
    CONSTRAINT fk_request_customer
        FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

CREATE INDEX idx_request_site ON request(site_id);
CREATE INDEX idx_request_customer ON request(customer_id);
CREATE INDEX idx_request_status ON request(request_status);
CREATE INDEX idx_request_period ON request(start_datetime, end_datetime);

------------------------------------------------------------
-- 4. security_task
------------------------------------------------------------
CREATE TABLE security_task (
    task_id             VARCHAR(36) PRIMARY KEY,
    request_id          VARCHAR(36) NOT NULL,
    task_name           VARCHAR(255) NOT NULL,
    task_description    TEXT,
    area_or_post        VARCHAR(255),
    required_language   VARCHAR(100),
    notes               TEXT,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP NOT NULL,
    CONSTRAINT fk_task_request
        FOREIGN KEY (request_id) REFERENCES request(request_id)
        ON DELETE CASCADE
);

CREATE INDEX idx_task_request ON security_task(request_id);

------------------------------------------------------------
-- 5. qualification_type
------------------------------------------------------------
CREATE TABLE qualification_type (
    qualification_type_id VARCHAR(36) PRIMARY KEY,
    qualification_code    VARCHAR(255) NOT NULL,
    description           TEXT,
    is_legal_requirement  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at            TIMESTAMP NOT NULL,
    updated_at            TIMESTAMP NOT NULL,
    CONSTRAINT uq_qualification_code UNIQUE (qualification_code)
);

CREATE INDEX idx_qualification_legal ON qualification_type(is_legal_requirement);

------------------------------------------------------------
-- 6. task_qualification (N:N)
------------------------------------------------------------
CREATE TABLE task_qualification (
    task_id               VARCHAR(36) NOT NULL,
    qualification_type_id VARCHAR(36) NOT NULL,
    requirement_level     VARCHAR(50),
    notes                 TEXT,
    created_at            TIMESTAMP NOT NULL,
    updated_at            TIMESTAMP NOT NULL,
    CONSTRAINT pk_task_qualification PRIMARY KEY (task_id, qualification_type_id),
    CONSTRAINT fk_tq_task FOREIGN KEY (task_id) REFERENCES security_task(task_id) ON DELETE CASCADE,
    CONSTRAINT fk_tq_qualification FOREIGN KEY (qualification_type_id) REFERENCES qualification_type(qualification_type_id)
);

CREATE INDEX idx_taskqual_qual ON task_qualification(qualification_type_id);

------------------------------------------------------------
-- 7. rate_profile
------------------------------------------------------------
CREATE TABLE rate_profile (
    rate_profile_id       VARCHAR(36) PRIMARY KEY,
    qualification_type_id VARCHAR(36),
    region_code           VARCHAR(100) NOT NULL,
    time_band             VARCHAR(50) NOT NULL,
    base_rate_cost_per_hour   NUMERIC(12,2) NOT NULL,
    base_rate_price_per_hour  NUMERIC(12,2) NOT NULL,
    surcharge_type        VARCHAR(100),
    surcharge_ratio       NUMERIC(5,2),
    valid_from            TIMESTAMP NOT NULL,
    valid_to              TIMESTAMP,
    created_at            TIMESTAMP NOT NULL,
    updated_at            TIMESTAMP NOT NULL,
    CONSTRAINT fk_rate_qualification
        FOREIGN KEY (qualification_type_id) REFERENCES qualification_type(qualification_type_id)
);

CREATE INDEX idx_rate_profile_lookup ON rate_profile(region_code, time_band, qualification_type_id);
CREATE INDEX idx_rate_profile_valid ON rate_profile(valid_from, valid_to);

------------------------------------------------------------
-- 8. shift_requirement
------------------------------------------------------------
CREATE TABLE shift_requirement (
    shift_req_id          VARCHAR(36) PRIMARY KEY,
    task_id               VARCHAR(36) NOT NULL,
    rate_profile_id       VARCHAR(36),
    shift_start_datetime  TIMESTAMP NOT NULL,
    shift_end_datetime    TIMESTAMP NOT NULL,
    required_headcount    INTEGER NOT NULL,
    risk_level_override   VARCHAR(50),
    location_detail_override TEXT,
    notes                 TEXT,
    created_at            TIMESTAMP NOT NULL,
    updated_at            TIMESTAMP NOT NULL,
    CONSTRAINT fk_shift_task
        FOREIGN KEY (task_id) REFERENCES security_task(task_id) ON DELETE CASCADE,
    CONSTRAINT fk_shift_rate
        FOREIGN KEY (rate_profile_id) REFERENCES rate_profile(rate_profile_id)
);

CREATE INDEX idx_shift_task ON shift_requirement(task_id);
CREATE INDEX idx_shift_rate ON shift_requirement(rate_profile_id);
CREATE INDEX idx_shift_time ON shift_requirement(shift_start_datetime, shift_end_datetime);

------------------------------------------------------------
-- 9. shiftreq_qualification (N:N)
------------------------------------------------------------
CREATE TABLE shiftreq_qualification (
    shift_req_id          VARCHAR(36) NOT NULL,
    qualification_type_id VARCHAR(36) NOT NULL,
    min_headcount_with_this_qual INTEGER,
    requirement_level     VARCHAR(50),
    notes                 TEXT,
    created_at            TIMESTAMP NOT NULL,
    updated_at            TIMESTAMP NOT NULL,
    CONSTRAINT pk_shiftreq_qualification PRIMARY KEY (shift_req_id, qualification_type_id),
    CONSTRAINT fk_srqual_shift FOREIGN KEY (shift_req_id) REFERENCES shift_requirement(shift_req_id) ON DELETE CASCADE,
    CONSTRAINT fk_srqual_qualification FOREIGN KEY (qualification_type_id) REFERENCES qualification_type(qualification_type_id)
);

CREATE INDEX idx_shiftqual_qual ON shiftreq_qualification(qualification_type_id);

------------------------------------------------------------
-- 10. quote (見積ヘッダ)
------------------------------------------------------------
CREATE TABLE quote (
    quote_id             VARCHAR(36) PRIMARY KEY,
    request_id           VARCHAR(36) NOT NULL,
    quote_version_no     INTEGER NOT NULL,
    quote_status         VARCHAR(50) NOT NULL,
    total_amount         NUMERIC(12,2) NOT NULL DEFAULT 0,
    currency             VARCHAR(10) NOT NULL DEFAULT 'JPY',
    valid_until_datetime TIMESTAMP,
    discount_note        TEXT,
    internal_margin_rate NUMERIC(5,2),
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT fk_quote_request
        FOREIGN KEY (request_id) REFERENCES request(request_id) ON DELETE CASCADE,
    CONSTRAINT uq_quote_request_version UNIQUE (request_id, quote_version_no)
);

CREATE INDEX idx_quote_request ON quote(request_id);
CREATE INDEX idx_quote_status ON quote(quote_status);

------------------------------------------------------------
-- 11. quote_line_item
------------------------------------------------------------
CREATE TABLE quote_line_item (
    quote_line_item_id   VARCHAR(36) PRIMARY KEY,
    quote_id             VARCHAR(36) NOT NULL,
    shift_req_id         VARCHAR(36),
    line_description     TEXT NOT NULL,
    unit_type            VARCHAR(50) NOT NULL,
    unit_price           NUMERIC(12,2) NOT NULL,
    quantity             NUMERIC(12,2) NOT NULL,
    line_amount          NUMERIC(12,2) NOT NULL,
    notes_customer_visible TEXT,
    notes_internal       TEXT,
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT fk_qli_quote FOREIGN KEY (quote_id) REFERENCES quote(quote_id) ON DELETE CASCADE,
    CONSTRAINT fk_qli_shift FOREIGN KEY (shift_req_id) REFERENCES shift_requirement(shift_req_id)
);

CREATE INDEX idx_qli_quote ON quote_line_item(quote_id);
CREATE INDEX idx_qli_shift ON quote_line_item(shift_req_id);

------------------------------------------------------------
-- 12. contract
------------------------------------------------------------
CREATE TABLE contract (
    contract_id          VARCHAR(36) PRIMARY KEY,
    quote_id             VARCHAR(36) NOT NULL,
    request_id           VARCHAR(36) NOT NULL,
    contract_status      VARCHAR(50) NOT NULL,
    agreed_amount        NUMERIC(12,2),
    start_datetime       TIMESTAMP NOT NULL,
    end_datetime         TIMESTAMP NOT NULL,
    terms_summary        TEXT,
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT fk_contract_quote FOREIGN KEY (quote_id) REFERENCES quote(quote_id),
    CONSTRAINT fk_contract_request FOREIGN KEY (request_id) REFERENCES request(request_id)
);

CREATE INDEX idx_contract_quote ON contract(quote_id);
CREATE INDEX idx_contract_request ON contract(request_id);
CREATE INDEX idx_contract_status ON contract(contract_status);

------------------------------------------------------------
-- 13. invoice
------------------------------------------------------------
CREATE TABLE invoice (
    invoice_id           VARCHAR(36) PRIMARY KEY,
    contract_id          VARCHAR(36) NOT NULL,
    invoice_number       VARCHAR(100) NOT NULL,
    billing_period_start DATE NOT NULL,
    billing_period_end   DATE NOT NULL,
    invoice_amount       NUMERIC(12,2) NOT NULL,
    tax_amount           NUMERIC(12,2) NOT NULL,
    total_with_tax       NUMERIC(12,2) NOT NULL,
    payment_due_date     DATE,
    payment_status       VARCHAR(50) NOT NULL,
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT fk_invoice_contract FOREIGN KEY (contract_id) REFERENCES contract(contract_id),
    CONSTRAINT uq_invoice_number UNIQUE (invoice_number)
);

CREATE INDEX idx_invoice_contract ON invoice(contract_id);
CREATE INDEX idx_invoice_status ON invoice(payment_status);
CREATE INDEX idx_invoice_period ON invoice(billing_period_start, billing_period_end);

------------------------------------------------------------
-- 14. risk_note
------------------------------------------------------------
CREATE TABLE risk_note (
    risk_note_id         VARCHAR(36) PRIMARY KEY,
    request_id           VARCHAR(36) NOT NULL,
    risk_category        VARCHAR(100) NOT NULL,
    risk_description     TEXT NOT NULL,
    mitigation_plan_summary TEXT,
    surcharge_implication_flag BOOLEAN NOT NULL DEFAULT FALSE,
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT fk_risk_request FOREIGN KEY (request_id) REFERENCES request(request_id) ON DELETE CASCADE
);

CREATE INDEX idx_risk_request ON risk_note(request_id);
CREATE INDEX idx_risk_category ON risk_note(risk_category);

------------------------------------------------------------
-- 15. attachment
------------------------------------------------------------
CREATE TABLE attachment (
    attachment_id        VARCHAR(36) PRIMARY KEY,
    request_id           VARCHAR(36) NOT NULL,
    file_name            VARCHAR(255) NOT NULL,
    file_type            VARCHAR(100) NOT NULL,
    storage_location     TEXT NOT NULL,
    description          TEXT,
    is_confidential      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT fk_attachment_request FOREIGN KEY (request_id) REFERENCES request(request_id) ON DELETE CASCADE
);

CREATE INDEX idx_attachment_request ON attachment(request_id);
CREATE INDEX idx_attachment_confidential ON attachment(is_confidential);

------------------------------------------------------------
-- 16. attachment_access_control (optional)
------------------------------------------------------------
CREATE TABLE attachment_access_control (
    attachment_id        VARCHAR(36) NOT NULL,
    role_code            VARCHAR(100) NOT NULL,
    access_level         VARCHAR(50) NOT NULL,
    created_at           TIMESTAMP NOT NULL,
    updated_at           TIMESTAMP NOT NULL,
    CONSTRAINT pk_attachment_access_control PRIMARY KEY (attachment_id, role_code),
    CONSTRAINT fk_aac_attachment FOREIGN KEY (attachment_id) REFERENCES attachment(attachment_id) ON DELETE CASCADE
);

CREATE INDEX idx_attach_acl_role ON attachment_access_control(role_code, access_level);

