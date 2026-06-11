# CT-Internship-Task-4

## Task 4 — Database Backup and Recovery

**File:** `task4_backup.sql`  
**Schema:** `task4_backup`

### What it does

Demonstrates how to create a backup of a PostgreSQL database and restore it after a simulated database failure.

### Steps

1. Load CSV data into the `task4_backup` schema
2. Verify data before backup (row count and total revenue)
3. Take a backup using the pgAdmin GUI
4. Drop tables to simulate database failure
5. Restore the database using the pgAdmin GUI
6. Verify restored data to ensure it matches the original data

---

## Backup Process (pgAdmin)

1. Right-click on the database
2. Select **Backup**
3. Enter filename: `codtech_backup`
4. Choose **Custom** format
5. Click **Backup**

---

## Restore Process (pgAdmin)

1. Right-click on the database
2. Select **Restore**
3. Choose the backup file
4. Click **Restore**

---

## Verification Queries

The script verifies the success of the restore process using:

- Row count comparison before and after restore
- Total revenue comparison before and after restore
- NULL value check
- Sample data validation
- Category-wise summary

---

## How to Run

1. Open `task4_backup.sql` in pgAdmin Query Tool
2. Update the CSV file path in the `COPY` command
3. Run **Phase 1** and **Phase 2**
4. Create a backup using the pgAdmin GUI
5. Run **Phase 3** (DROP tables)
6. Restore the database using the pgAdmin GUI
7. Run **Phase 4** (verification queries)
8. 
