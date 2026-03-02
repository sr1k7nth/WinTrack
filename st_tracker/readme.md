# Execution Flow & Thread Architecture

## Application Startup Flow

The application entry point initializes the GUI and starts all background components:

```python
window = ButtonHolder()
window.show()
app.exec()
```

### Step-by-Step Execution

1. `ButtonHolder()` is instantiated (main GUI controller).
2. A `QThread` is created (not yet started).
3. A `TrackerWorker` instance is initialized.
4. A standard Python `Thread` is created to run the FastAPI server:

```python
self.api_thread = Thread(target=run_api, daemon=True)
self.api_thread.start()
```

5. The worker is moved to the QThread:

```python
self.worker.moveToThread(self.thread)
```

This ensures the worker executes outside the GUI thread.

6. When the thread starts, it triggers:

```python
self.thread.started.connect(self.worker.run)
```

7. When the worker finishes, it signals the thread to quit:

```python
self.worker.finished.connect(self.thread.quit)
```

8. The worker thread is started:

```python
self.thread.start()
```

9. Finally, `app.exec()` starts the main Qt event loop.

---

## Thread Architecture

```
Thread 1 — Main GUI Thread
    - PySide6 event loop
    - System tray
    - UI components

Thread 2 — QThread
    - TrackerWorker.run()
    - Active window polling
    - Idle detection
    - Usage accumulation

Thread 3 — Python Thread
    - FastAPI / Uvicorn server
    - Serves dashboard API
```

---

## Why QThread + Thread?

* `QThread` is used for the tracking worker because it integrates properly with Qt’s signal-slot system.
* A standard `threading.Thread` is sufficient for running FastAPI since it does not need Qt signal integration.
* This separation prevents UI blocking and ensures smooth system tray interaction.

---

## Why PySide6 Over Tkinter?

Qt provides:

* Native thread management (`QThread`)
* Signal-slot communication
* Better event loop integration
* Cleaner background task handling

This architecture would be significantly harder to implement cleanly in Tkinter.

