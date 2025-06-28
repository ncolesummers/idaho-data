# Idaho Data API - TDD-Driven 6-Week Backlog

**Project:** Idaho Data Explorer API  
**Duration:** 6 Weeks  
**Methodology:** Test-Driven Development (Red-Green-Refactor)  
**Platform:** GitHub Issues  

---

## Sprint 1: Foundation (Week 1)
**Sprint Goal:** Establish TDD practice with basic API functionality

### Issue #1: Health Check Endpoint
**Type:** User Story  
**Labels:** `sprint-1`, `foundation`  
**Assignee:** Developer

**As a** DevOps engineer  
**I want** a health check endpoint  
**So that** I can monitor if the API is running

**Definition of Done:**
- [ ] All tests pass
- [ ] Code coverage > 80%
- [ ] Endpoint responds with proper JSON
- [ ] Documentation updated

#### Task #1.1: Write Health Check Tests (Red Phase)
**Labels:** `task`, `testing`  
**Time Estimate:** 1 hour

Create `internal/handlers/health_test.go`:
```go
package handlers_test

import (
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestHealthCheck_ReturnsOK(t *testing.T) {
    // Arrange
    req, err := http.NewRequest("GET", "/health", nil)
    require.NoError(t, err)
    
    rr := httptest.NewRecorder()
    
    // Act
    handler := http.HandlerFunc(handlers.HealthCheck) // This will fail - handler doesn't exist
    handler.ServeHTTP(rr, req)
    
    // Assert
    assert.Equal(t, http.StatusOK, rr.Code)
    
    var response map[string]string
    err = json.Unmarshal(rr.Body.Bytes(), &response)
    require.NoError(t, err)
    
    assert.Equal(t, "ok", response["status"])
}

func TestHealthCheck_ReturnsJSON(t *testing.T) {
    // Arrange
    req, err := http.NewRequest("GET", "/health", nil)
    require.NoError(t, err)
    
    rr := httptest.NewRecorder()
    
    // Act
    handler := http.HandlerFunc(handlers.HealthCheck)
    handler.ServeHTTP(rr, req)
    
    // Assert
    assert.Equal(t, "application/json", rr.Header().Get("Content-Type"))
}

func TestHealthCheck_MethodNotAllowed(t *testing.T) {
    // Test that POST, PUT, DELETE return 405
    methods := []string{"POST", "PUT", "DELETE"}
    
    for _, method := range methods {
        t.Run(method, func(t *testing.T) {
            req, err := http.NewRequest(method, "/health", nil)
            require.NoError(t, err)
            
            rr := httptest.NewRecorder()
            handler := http.HandlerFunc(handlers.HealthCheck)
            handler.ServeHTTP(rr, req)
            
            assert.Equal(t, http.StatusMethodNotAllowed, rr.Code)
        })
    }
}
```

**Checklist:**
- [ ] Create test file
- [ ] Write test for successful response
- [ ] Write test for content-type header
- [ ] Write test for unsupported methods
- [ ] Run tests and confirm they fail

#### Task #1.2: Implement Health Check Handler (Green Phase)
**Labels:** `task`, `implementation`  
**Time Estimate:** 45 minutes

Create `internal/handlers/health.go`:
```go
package handlers

import (
    "encoding/json"
    "net/http"
)

func HealthCheck(w http.ResponseWriter, r *http.Request) {
    if r.Method != http.MethodGet {
        w.WriteHeader(http.StatusMethodNotAllowed)
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    
    response := map[string]string{
        "status": "ok",
    }
    
    json.NewEncoder(w).Encode(response)
}
```

**Checklist:**
- [ ] Create handler file
- [ ] Implement method checking
- [ ] Set proper headers
- [ ] Return JSON response
- [ ] Run tests and confirm they pass

#### Task #1.3: Refactor and Add Integration Test
**Labels:** `task`, `refactoring`  
**Time Estimate:** 30 minutes

Create `cmd/server/main_test.go`:
```go
package main_test

import (
    "net/http"
    "testing"
    "time"
)

func TestServerStarts(t *testing.T) {
    go main() // Start server in goroutine
    
    time.Sleep(100 * time.Millisecond) // Wait for startup
    
    resp, err := http.Get("http://localhost:8080/health")
    if err != nil {
        t.Fatalf("Could not reach server: %v", err)
    }
    defer resp.Body.Close()
    
    if resp.StatusCode != http.StatusOK {
        t.Errorf("Expected status 200, got %d", resp.StatusCode)
    }
}
```

---

### Issue #2: Salary Query Endpoint with Mock Data
**Type:** User Story  
**Labels:** `sprint-1`, `api`  
**Assignee:** Developer

**As a** data analyst  
**I want** to query salary data by department and year  
**So that** I can analyze compensation patterns

**Definition of Done:**
- [ ] All tests pass
- [ ] Query parameters validated
- [ ] Error responses follow consistent format
- [ ] Mock data returns predictable values

#### Task #2.1: Write Salary Endpoint Tests
**Labels:** `task`, `testing`  
**Time Estimate:** 1.5 hours

Create `internal/handlers/salary_test.go`:
```go
package handlers_test

import (
    "encoding/json"
    "fmt"
    "net/http"
    "net/http/httptest"
    "testing"
)

type SalaryResponse struct {
    Department string  `json:"department"`
    Year       string  `json:"year"`
    Average    float64 `json:"average"`
    Median     float64 `json:"median"`
    Count      int     `json:"count"`
    Error      string  `json:"error,omitempty"`
}

func TestGetSalaries_ValidRequest(t *testing.T) {
    tests := []struct {
        name       string
        dept       string
        year       string
        wantAvg    float64
        wantMedian float64
        wantCount  int
    }{
        {
            name:       "Computer Science 2024",
            dept:       "CS",
            year:       "2024",
            wantAvg:    78432.50,
            wantMedian: 72000.00,
            wantCount:  47,
        },
        {
            name:       "Mathematics 2024",
            dept:       "MATH",
            year:       "2024",
            wantAvg:    68500.00,
            wantMedian: 65000.00,
            wantCount:  32,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            url := fmt.Sprintf("/api/salaries?dept=%s&year=%s", tt.dept, tt.year)
            req, err := http.NewRequest("GET", url, nil)
            require.NoError(t, err)
            
            rr := httptest.NewRecorder()
            handler := http.HandlerFunc(handlers.GetSalaries)
            handler.ServeHTTP(rr, req)
            
            assert.Equal(t, http.StatusOK, rr.Code)
            
            var response SalaryResponse
            err = json.Unmarshal(rr.Body.Bytes(), &response)
            require.NoError(t, err)
            
            assert.Equal(t, tt.dept, response.Department)
            assert.Equal(t, tt.year, response.Year)
            assert.Equal(t, tt.wantAvg, response.Average)
            assert.Equal(t, tt.wantMedian, response.Median)
            assert.Equal(t, tt.wantCount, response.Count)
        })
    }
}

func TestGetSalaries_MissingParameters(t *testing.T) {
    tests := []struct {
        name    string
        url     string
        wantErr string
    }{
        {
            name:    "Missing department",
            url:     "/api/salaries?year=2024",
            wantErr: "Missing required parameter: dept",
        },
        {
            name:    "Missing year",
            url:     "/api/salaries?dept=CS",
            wantErr: "Missing required parameter: year",
        },
        {
            name:    "Missing both",
            url:     "/api/salaries",
            wantErr: "Missing required parameters: dept, year",
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            req, err := http.NewRequest("GET", tt.url, nil)
            require.NoError(t, err)
            
            rr := httptest.NewRecorder()
            handler := http.HandlerFunc(handlers.GetSalaries)
            handler.ServeHTTP(rr, req)
            
            assert.Equal(t, http.StatusBadRequest, rr.Code)
            
            var response SalaryResponse
            err = json.Unmarshal(rr.Body.Bytes(), &response)
            require.NoError(t, err)
            
            assert.Equal(t, tt.wantErr, response.Error)
        })
    }
}

func TestGetSalaries_InvalidYear(t *testing.T) {
    req, err := http.NewRequest("GET", "/api/salaries?dept=CS&year=2030", nil)
    require.NoError(t, err)
    
    rr := httptest.NewRecorder()
    handler := http.HandlerFunc(handlers.GetSalaries)
    handler.ServeHTTP(rr, req)
    
    assert.Equal(t, http.StatusBadRequest, rr.Code)
    
    var response SalaryResponse
    err = json.Unmarshal(rr.Body.Bytes(), &response)
    require.NoError(t, err)
    
    assert.Equal(t, "Invalid year: must be between 2020 and 2024", response.Error)
}

func TestGetSalaries_UnknownDepartment(t *testing.T) {
    req, err := http.NewRequest("GET", "/api/salaries?dept=UNKNOWN&year=2024", nil)
    require.NoError(t, err)
    
    rr := httptest.NewRecorder()
    handler := http.HandlerFunc(handlers.GetSalaries)
    handler.ServeHTTP(rr, req)
    
    assert.Equal(t, http.StatusOK, rr.Code)
    
    var response SalaryResponse
    err = json.Unmarshal(rr.Body.Bytes(), &response)
    require.NoError(t, err)
    
    assert.Equal(t, "UNKNOWN", response.Department)
    assert.Equal(t, 0, response.Count)
    assert.Equal(t, float64(0), response.Average)
}
```

#### Task #2.2: Implement Salary Handler
**Labels:** `task`, `implementation`  
**Time Estimate:** 1.5 hours

Create handler implementation to make tests pass.

**Checklist:**
- [ ] Parameter validation
- [ ] Year range validation (2020-2024)
- [ ] Mock data map for different departments
- [ ] Proper error responses
- [ ] All tests passing

---

## Sprint 2: Real Data (Week 2)
**Sprint Goal:** Replace mocks with real data from CSV

### Issue #3: CSV Data Parser
**Type:** User Story  
**Labels:** `sprint-2`, `data`  
**Assignee:** Developer

**As a** developer  
**I want** to parse Transparent Idaho CSV files  
**So that** the API can serve real data

#### Task #3.1: Write CSV Parser Tests
**Labels:** `task`, `testing`  
**Time Estimate:** 2 hours

Create `internal/data/parser_test.go`:
```go
package data_test

import (
    "strings"
    "testing"
)

func TestParseCSV_ValidData(t *testing.T) {
    csvData := `Name,Department,Position,Salary,Year
John Doe,Computer Science,Professor,95000.50,2024
Jane Smith,Computer Science,Assistant Professor,75000.00,2024
Bob Johnson,Mathematics,Professor,88000.00,2024`

    reader := strings.NewReader(csvData)
    records, err := data.ParseSalaryCSV(reader)
    
    require.NoError(t, err)
    assert.Len(t, records, 3)
    
    // Verify first record
    assert.Equal(t, "John Doe", records[0].Name)
    assert.Equal(t, "Computer Science", records[0].Department)
    assert.Equal(t, "Professor", records[0].Position)
    assert.Equal(t, 95000.50, records[0].Salary)
    assert.Equal(t, 2024, records[0].Year)
}

func TestParseCSV_InvalidSalary(t *testing.T) {
    csvData := `Name,Department,Position,Salary,Year
John Doe,Computer Science,Professor,invalid,2024`

    reader := strings.NewReader(csvData)
    records, err := data.ParseSalaryCSV(reader)
    
    require.NoError(t, err)
    assert.Len(t, records, 0) // Invalid records are skipped
}

func TestParseCSV_EmptyFile(t *testing.T) {
    csvData := `Name,Department,Position,Salary,Year`
    
    reader := strings.NewReader(csvData)
    records, err := data.ParseSalaryCSV(reader)
    
    require.NoError(t, err)
    assert.Len(t, records, 0)
}

func TestParseCSV_MissingColumns(t *testing.T) {
    csvData := `Name,Department,Salary
John Doe,Computer Science,95000`

    reader := strings.NewReader(csvData)
    _, err := data.ParseSalaryCSV(reader)
    
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "missing required columns")
}

func TestParseCSV_DifferentColumnOrder(t *testing.T) {
    csvData := `Year,Salary,Name,Position,Department
2024,95000.50,John Doe,Professor,Computer Science`

    reader := strings.NewReader(csvData)
    records, err := data.ParseSalaryCSV(reader)
    
    require.NoError(t, err)
    assert.Len(t, records, 1)
    assert.Equal(t, "John Doe", records[0].Name)
}

func TestParseCSV_ExtraWhitespace(t *testing.T) {
    csvData := `Name,Department,Position,Salary,Year
  John Doe  , Computer Science ,Professor, 95000.50 ,2024`

    reader := strings.NewReader(csvData)
    records, err := data.ParseSalaryCSV(reader)
    
    require.NoError(t, err)
    assert.Equal(t, "John Doe", records[0].Name) // Trimmed
    assert.Equal(t, "Computer Science", records[0].Department) // Trimmed
}
```

#### Task #3.2: Implement CSV Parser
**Labels:** `task`, `implementation`  
**Time Estimate:** 2 hours

Implement parser to make all tests pass.

---

### Issue #4: Data Fetcher with Retries
**Type:** User Story  
**Labels:** `sprint-2`, `data`, `reliability`  
**Assignee:** Developer

**As a** developer  
**I want** reliable data fetching with retries  
**So that** temporary network issues don't break the API

#### Task #4.1: Write Fetcher Tests with Mocked HTTP
**Labels:** `task`, `testing`  
**Time Estimate:** 1.5 hours

Create `internal/data/fetcher_test.go`:
```go
package data_test

import (
    "fmt"
    "net/http"
    "net/http/httptest"
    "testing"
    "time"
)

func TestFetchData_Success(t *testing.T) {
    // Mock server that returns CSV
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "text/csv")
        fmt.Fprint(w, `Name,Department,Position,Salary,Year
John Doe,CS,Professor,95000,2024`)
    }))
    defer server.Close()
    
    fetcher := data.NewFetcher(data.FetcherConfig{
        Timeout: 5 * time.Second,
        Retries: 3,
    })
    
    records, err := fetcher.FetchSalaryData(server.URL)
    
    require.NoError(t, err)
    assert.Len(t, records, 1)
}

func TestFetchData_RetryOnFailure(t *testing.T) {
    attempts := 0
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        attempts++
        if attempts < 3 {
            w.WriteHeader(http.StatusInternalServerError)
            return
        }
        fmt.Fprint(w, `Name,Department,Position,Salary,Year
John Doe,CS,Professor,95000,2024`)
    }))
    defer server.Close()
    
    fetcher := data.NewFetcher(data.FetcherConfig{
        Timeout: 5 * time.Second,
        Retries: 3,
    })
    
    records, err := fetcher.FetchSalaryData(server.URL)
    
    require.NoError(t, err)
    assert.Len(t, records, 1)
    assert.Equal(t, 3, attempts) // Should retry twice before succeeding
}

func TestFetchData_Timeout(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        time.Sleep(2 * time.Second) // Longer than timeout
    }))
    defer server.Close()
    
    fetcher := data.NewFetcher(data.FetcherConfig{
        Timeout: 100 * time.Millisecond,
        Retries: 1,
    })
    
    _, err := fetcher.FetchSalaryData(server.URL)
    
    assert.Error(t, err)
    assert.Contains(t, err.Error(), "timeout")
}

func TestFetchData_ExponentialBackoff(t *testing.T) {
    attempts := 0
    timestamps := []time.Time{}
    
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        attempts++
        timestamps = append(timestamps, time.Now())
        w.WriteHeader(http.StatusInternalServerError)
    }))
    defer server.Close()
    
    fetcher := data.NewFetcher(data.FetcherConfig{
        Timeout: 5 * time.Second,
        Retries: 3,
        BackoffBase: 100 * time.Millisecond,
    })
    
    _, err := fetcher.FetchSalaryData(server.URL)
    
    assert.Error(t, err)
    assert.Equal(t, 3, attempts)
    
    // Verify exponential backoff
    if len(timestamps) >= 3 {
        gap1 := timestamps[1].Sub(timestamps[0])
        gap2 := timestamps[2].Sub(timestamps[1])
        
        // Second gap should be roughly 2x the first
        ratio := float64(gap2) / float64(gap1)
        assert.Greater(t, ratio, 1.8)
        assert.Less(t, ratio, 2.2)
    }
}
```

---

## Sprint 3: Event System (Week 3)
**Sprint Goal:** Add event-driven architecture foundation

### Issue #5: Event Bus Implementation
**Type:** User Story  
**Labels:** `sprint-3`, `architecture`  
**Assignee:** Developer

**As a** developer  
**I want** an event system for tracking operations  
**So that** I can understand system behavior and add features without modifying core code

#### Task #5.1: Write Event Bus Tests
**Labels:** `task`, `testing`  
**Time Estimate:** 2 hours

Create `internal/events/bus_test.go`:
```go
package events_test

import (
    "sync"
    "testing"
    "time"
)

func TestEventBus_PublishSubscribe(t *testing.T) {
    bus := events.NewBus()
    received := make(chan events.Event, 1)
    
    // Subscribe
    bus.Subscribe("test.event", func(e events.Event) {
        received <- e
    })
    
    // Publish
    event := events.NewBaseEvent("test.event", map[string]interface{}{
        "message": "hello",
    })
    bus.Publish(event)
    
    // Verify
    select {
    case e := <-received:
        assert.Equal(t, "test.event", e.Type())
        assert.Equal(t, "hello", e.Data()["message"])
    case <-time.After(100 * time.Millisecond):
        t.Fatal("Event not received")
    }
}

func TestEventBus_MultipleSubscribers(t *testing.T) {
    bus := events.NewBus()
    var wg sync.WaitGroup
    received := make([]string, 0)
    var mu sync.Mutex
    
    // Three subscribers
    for i := 0; i < 3; i++ {
        wg.Add(1)
        id := fmt.Sprintf("subscriber-%d", i)
        bus.Subscribe("test.event", func(e events.Event) {
            mu.Lock()
            received = append(received, id)
            mu.Unlock()
            wg.Done()
        })
    }
    
    // Publish once
    bus.Publish(events.NewBaseEvent("test.event", nil))
    
    // Wait for all
    wg.Wait()
    
    assert.Len(t, received, 3)
}

func TestEventBus_UnsubscribedEvents(t *testing.T) {
    bus := events.NewBus()
    
    // Publish without subscribers shouldn't panic
    assert.NotPanics(t, func() {
        bus.Publish(events.NewBaseEvent("unsubscribed.event", nil))
    })
}

func TestEventBus_ConcurrentPublish(t *testing.T) {
    bus := events.NewBus()
    count := int32(0)
    
    bus.Subscribe("concurrent.event", func(e events.Event) {
        atomic.AddInt32(&count, 1)
    })
    
    // Publish from multiple goroutines
    var wg sync.WaitGroup
    for i := 0; i < 100; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            bus.Publish(events.NewBaseEvent("concurrent.event", nil))
        }()
    }
    
    wg.Wait()
    time.Sleep(50 * time.Millisecond) // Let handlers finish
    
    assert.Equal(t, int32(100), atomic.LoadInt32(&count))
}
```

---

## Sprint 4: Performance & Caching (Week 4)
**Sprint Goal:** Add caching layer with metrics

### Issue #6: SQLite Cache Layer
**Type:** User Story  
**Labels:** `sprint-4`, `performance`  
**Assignee:** Developer

**As a** user  
**I want** query results to be cached  
**So that** repeated queries are instant

#### Task #6.1: Write Cache Interface Tests
**Labels:** `task`, `testing`  
**Time Estimate:** 1.5 hours

Create `internal/cache/cache_test.go`:
```go
package cache_test

import (
    "testing"
    "time"
)

func TestCache_GetSet(t *testing.T) {
    cache := cache.NewMemoryCache() // Start with memory implementation
    
    // Test miss
    _, found := cache.Get("missing-key")
    assert.False(t, found)
    
    // Test set and get
    err := cache.Set("key1", "value1", 1*time.Hour)
    require.NoError(t, err)
    
    value, found := cache.Get("key1")
    assert.True(t, found)
    assert.Equal(t, "value1", value)
}

func TestCache_Expiration(t *testing.T) {
    cache := cache.NewMemoryCache()
    
    // Set with short TTL
    err := cache.Set("expire-key", "value", 100*time.Millisecond)
    require.NoError(t, err)
    
    // Should exist immediately
    _, found := cache.Get("expire-key")
    assert.True(t, found)
    
    // Should not exist after expiration
    time.Sleep(150 * time.Millisecond)
    _, found = cache.Get("expire-key")
    assert.False(t, found)
}

func TestCache_Delete(t *testing.T) {
    cache := cache.NewMemoryCache()
    
    cache.Set("delete-key", "value", 1*time.Hour)
    
    err := cache.Delete("delete-key")
    require.NoError(t, err)
    
    _, found := cache.Get("delete-key")
    assert.False(t, found)
}

func TestCache_Clear(t *testing.T) {
    cache := cache.NewMemoryCache()
    
    // Add multiple items
    cache.Set("key1", "value1", 1*time.Hour)
    cache.Set("key2", "value2", 1*time.Hour)
    cache.Set("key3", "value3", 1*time.Hour)
    
    // Clear all
    err := cache.Clear()
    require.NoError(t, err)
    
    // Verify all gone
    _, found1 := cache.Get("key1")
    _, found2 := cache.Get("key2")
    _, found3 := cache.Get("key3")
    
    assert.False(t, found1)
    assert.False(t, found2)
    assert.False(t, found3)
}
```

#### Task #6.2: Write SQLite Cache Tests
**Labels:** `task`, `testing`  
**Time Estimate:** 2 hours

Create `internal/cache/sqlite_test.go`:
```go
package cache_test

import (
    "os"
    "testing"
)

func TestSQLiteCache_Persistence(t *testing.T) {
    dbPath := "test_cache.db"
    defer os.Remove(dbPath)
    
    // Create cache and add data
    cache1, err := cache.NewSQLiteCache(dbPath)
    require.NoError(t, err)
    
    err = cache1.Set("persist-key", "persist-value", 1*time.Hour)
    require.NoError(t, err)
    
    cache1.Close()
    
    // Create new cache instance
    cache2, err := cache.NewSQLiteCache(dbPath)
    require.NoError(t, err)
    defer cache2.Close()
    
    // Data should persist
    value, found := cache2.Get("persist-key")
    assert.True(t, found)
    assert.Equal(t, "persist-value", value)
}

func TestSQLiteCache_ConcurrentAccess(t *testing.T) {
    dbPath := "test_concurrent.db"
    defer os.Remove(dbPath)
    
    cache, err := cache.NewSQLiteCache(dbPath)
    require.NoError(t, err)
    defer cache.Close()
    
    // Concurrent writes
    var wg sync.WaitGroup
    for i := 0; i < 10; i++ {
        wg.Add(1)
        go func(n int) {
            defer wg.Done()
            key := fmt.Sprintf("key-%d", n)
            value := fmt.Sprintf("value-%d", n)
            err := cache.Set(key, value, 1*time.Hour)
            assert.NoError(t, err)
        }(i)
    }
    
    wg.Wait()
    
    // Verify all written
    for i := 0; i < 10; i++ {
        key := fmt.Sprintf("key-%d", i)
        expectedValue := fmt.Sprintf("value-%d", i)
        
        value, found := cache.Get(key)
        assert.True(t, found)
        assert.Equal(t, expectedValue, value)
    }
}
```

---

## Sprint 5: Monitoring & Metrics (Week 5)
**Sprint Goal:** Add comprehensive monitoring

### Issue #7: Metrics Collection System
**Type:** User Story  
**Labels:** `sprint-5`, `observability`  
**Assignee:** Developer

**As a** developer  
**I want** detailed metrics about API performance  
**So that** I can identify and fix bottlenecks

#### Task #7.1: Write Metrics Collector Tests
**Labels:** `task`, `testing`  
**Time Estimate:** 1.5 hours

Create `internal/metrics/collector_test.go`:
```go
package metrics_test

import (
    "testing"
    "time"
)

func TestCollector_RecordLatency(t *testing.T) {
    collector := metrics.NewCollector()
    
    // Record some latencies
    collector.RecordLatency("api.request", 100*time.Millisecond)
    collector.RecordLatency("api.request", 200*time.Millisecond)
    collector.RecordLatency("api.request", 150*time.Millisecond)
    
    stats := collector.GetStats("api.request")
    
    assert.Equal(t, 3, stats.Count)
    assert.Equal(t, 150*time.Millisecond, stats.Average)
    assert.Equal(t, 150*time.Millisecond, stats.Median)
    assert.Equal(t, 100*time.Millisecond, stats.Min)
    assert.Equal(t, 200*time.Millisecond, stats.Max)
}

func TestCollector_Percentiles(t *testing.T) {
    collector := metrics.NewCollector()
    
    // Record 100 latencies
    for i := 1; i <= 100; i++ {
        latency := time.Duration(i) * time.Millisecond
        collector.RecordLatency("test.metric", latency)
    }
    
    stats := collector.GetStats("test.metric")
    
    assert.Equal(t, 50*time.Millisecond, stats.P50)
    assert.Equal(t, 90*time.Millisecond, stats.P90)
    assert.Equal(t, 95*time.Millisecond, stats.P95)
    assert.Equal(t, 99*time.Millisecond, stats.P99)
}

func TestCollector_WindowedMetrics(t *testing.T) {
    collector := metrics.NewCollector(metrics.WithWindow(100*time.Millisecond))
    
    // Record old metric
    collector.RecordLatency("windowed", 100*time.Millisecond)
    
    // Wait for window to pass
    time.Sleep(150 * time.Millisecond)
    
    // Record new metric
    collector.RecordLatency("windowed", 200*time.Millisecond)
    
    stats := collector.GetStats("windowed")
    
    // Should only include recent metric
    assert.Equal(t, 1, stats.Count)
    assert.Equal(t, 200*time.Millisecond, stats.Average)
}

func TestCollector_MultipleMetrics(t *testing.T) {
    collector := metrics.NewCollector()
    
    collector.RecordLatency("metric.a", 100*time.Millisecond)
    collector.RecordLatency("metric.b", 200*time.Millisecond)
    
    allStats := collector.GetAllStats()
    
    assert.Len(t, allStats, 2)
    assert.Contains(t, allStats, "metric.a")
    assert.Contains(t, allStats, "metric.b")
}
```

---

## Sprint 6: Production Readiness (Week 6)
**Sprint Goal:** Polish, documentation, and deployment readiness

### Issue #8: End-to-End Integration Tests
**Type:** User Story  
**Labels:** `sprint-6`, `testing`  
**Assignee:** Developer

**As a** developer  
**I want** comprehensive integration tests  
**So that** I can deploy with confidence

#### Task #8.1: Write E2E Test Suite
**Labels:** `task`, `testing`  
**Time Estimate:** 3 hours

Create `test/e2e/api_test.go`:
```go
package e2e_test

import (
    "encoding/json"
    "net/http"
    "os"
    "testing"
    "time"
)

func TestE2E_FullUserJourney(t *testing.T) {
    if testing.Short() {
        t.Skip("Skipping E2E test in short mode")
    }
    
    // Start server
    baseURL := startTestServer(t)
    
    // 1. Check health
    resp, err := http.Get(baseURL + "/health")
    require.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
    
    // 2. Query salaries (should trigger data fetch)
    start := time.Now()
    resp, err = http.Get(baseURL + "/api/salaries?dept=CS&year=2024")
    require.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
    
    firstCallDuration := time.Since(start)
    
    var salaryResp SalaryResponse
    json.NewDecoder(resp.Body).Decode(&salaryResp)
    assert.Greater(t, salaryResp.Count, 0)
    
    // 3. Same query again (should be cached)
    start = time.Now()
    resp, err = http.Get(baseURL + "/api/salaries?dept=CS&year=2024")
    require.NoError(t, err)
    
    cachedCallDuration := time.Since(start)
    
    // Cached call should be much faster
    assert.Less(t, cachedCallDuration, firstCallDuration/2)
    
    // 4. Check metrics
    resp, err = http.Get(baseURL + "/api/metrics")
    require.NoError(t, err)
    
    var metrics map[string]interface{}
    json.NewDecoder(resp.Body).Decode(&metrics)
    
    assert.Contains(t, metrics, "api.salaries")
    assert.Contains(t, metrics, "cache.hits")
    assert.Contains(t, metrics, "cache.misses")
}

func TestE2E_ErrorHandling(t *testing.T) {
    baseURL := startTestServer(t)
    
    tests := []struct {
        name       string
        url        string
        wantStatus int
    }{
        {
            name:       "Missing parameters",
            url:        "/api/salaries",
            wantStatus: http.StatusBadRequest,
        },
        {
            name:       "Invalid year",
            url:        "/api/salaries?dept=CS&year=3000",
            wantStatus: http.StatusBadRequest,
        },
        {
            name:       "Non-existent endpoint",
            url:        "/api/nonexistent",
            wantStatus: http.StatusNotFound,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            resp, err := http.Get(baseURL + tt.url)
            require.NoError(t, err)
            assert.Equal(t, tt.wantStatus, resp.StatusCode)
        })
    }
}

func TestE2E_ConcurrentRequests(t *testing.T) {
    baseURL := startTestServer(t)
    
    // Warm up cache
    http.Get(baseURL + "/api/salaries?dept=CS&year=2024")
    
    // Concurrent requests
    const numRequests = 50
    errors := make(chan error, numRequests)
    
    for i := 0; i < numRequests; i++ {
        go func() {
            resp, err := http.Get(baseURL + "/api/salaries?dept=CS&year=2024")
            if err != nil {
                errors <- err
                return
            }
            if resp.StatusCode != http.StatusOK {
                errors <- fmt.Errorf("bad status: %d", resp.StatusCode)
                return
            }
            errors <- nil
        }()
    }
    
    // Collect results
    for i := 0; i < numRequests; i++ {
        err := <-errors
        assert.NoError(t, err)
    }
}
```

---

## GitHub Issue Templates

### User Story Template
```yaml
name: User Story
about: Define a new feature from user perspective
title: "[STORY] "
labels: story
assignees: ''

body:
  - type: textarea
    id: story
    attributes:
      label: User Story
      description: As a [type of user], I want [goal] so that [benefit]
      placeholder: |
        As a data analyst
        I want to query salary data by department
        So that I can analyze compensation patterns
    validations:
      required: true
      
  - type: textarea
    id: acceptance
    attributes:
      label: Acceptance Criteria
      description: List the conditions that must be met
      placeholder: |
        - [ ] Query returns JSON data
        - [ ] Parameters are validated
        - [ ] Errors return proper status codes
    validations:
      required: true
      
  - type: textarea
    id: tasks
    attributes:
      label: Tasks
      description: Break down into TDD tasks
      placeholder: |
        - [ ] Write failing tests
        - [ ] Implement feature
        - [ ] Refactor if needed
```

### Task Template
```yaml
name: Task
about: Technical task for implementing functionality
title: "[TASK] "
labels: task
assignees: ''

body:
  - type: dropdown
    id: type
    attributes:
      label: Task Type
      options:
        - Testing (Red Phase)
        - Implementation (Green Phase)
        - Refactoring
        - Documentation
    validations:
      required: true
      
  - type: textarea
    id: description
    attributes:
      label: Description
      description: What needs to be done
    validations:
      required: true
      
  - type: textarea
    id: checklist
    attributes:
      label: Checklist
      description: Specific items to complete
      placeholder: |
        - [ ] Create test file
        - [ ] Write test cases
        - [ ] Verify tests fail
        - [ ] Implement feature
        - [ ] Verify tests pass
```

---

## Definition of Ready (for Stories)
- [ ] Clear user story in standard format
- [ ] Acceptance criteria defined
- [ ] Test scenarios identified
- [ ] Dependencies identified
- [ ] Estimated in story points

## Definition of Done (for Stories)
- [ ] All tests written and passing
- [ ] Code coverage > 80%
- [ ] Code reviewed (or self-reviewed)
- [ ] Documentation updated
- [ ] No TODO comments
- [ ] Performance within requirements
- [ ] Error handling complete
- [ ] Logging added

---

### Issue #3: Project Setup and Configuration
**Type:** Epic  
**Labels:** `sprint-0`, `setup`  
**Assignee:** Developer

**As a** developer  
**I want** proper project configuration and tooling  
**So that** development is consistent and automated

#### Task #3.1: Create .gitignore and .editorconfig files
**Labels:** `task`, `sprint-0`  
**Size:** XS  
**Priority:** P0  
**Time Estimate:** 15 minutes

Create standard Go project configuration files:

**Checklist:**
- [ ] Create .gitignore with Go patterns
- [ ] Include IDE-specific excludes
- [ ] Add build artifacts and binaries
- [ ] Create .editorconfig for consistent formatting
- [ ] Set proper indentation rules for Go

#### Task #3.2: Create Makefile with common commands
**Labels:** `task`, `sprint-0`  
**Size:** S  
**Priority:** P0  
**Time Estimate:** 30 minutes

Create Makefile for common development tasks:

**Checklist:**
- [ ] Add build targets for different platforms
- [ ] Include test commands with coverage
- [ ] Add lint and format targets
- [ ] Include run and clean commands
- [ ] Add help target with documentation

---

### Issue #4: CI/CD Pipeline
**Type:** User Story  
**Labels:** `sprint-0`, `devops`  
**Assignee:** Developer

**As a** developer  
**I want** automated CI/CD pipeline  
**So that** code quality is maintained automatically

#### Task #4.1: Write GitHub Actions CI workflow
**Labels:** `task`, `sprint-0`  
**Size:** S  
**Priority:** P0  
**Time Estimate:** 45 minutes

Create .github/workflows/ci.yml:

**Checklist:**
- [ ] Set up Go environment
- [ ] Run tests on multiple Go versions
- [ ] Generate and upload coverage reports
- [ ] Run linting checks
- [ ] Build binaries for multiple platforms
- [ ] Cache dependencies for faster builds
- [ ] Set up matrix strategy for OS testing

---

### Issue #5: Code Quality Tools
**Type:** User Story  
**Labels:** `sprint-0`, `quality`  
**Assignee:** Developer

**As a** developer  
**I want** automated code quality checks  
**So that** code standards are enforced consistently

#### Task #5.1: Configure golangci-lint
**Labels:** `task`, `sprint-0`  
**Size:** S  
**Priority:** P0  
**Time Estimate:** 30 minutes

Set up comprehensive linting configuration:

**Checklist:**
- [ ] Create .golangci.yml configuration
- [ ] Enable appropriate linters for Go best practices
- [ ] Configure error handling checks
- [ ] Set up complexity thresholds
- [ ] Add custom lint rules if needed
- [ ] Document linting rules in README

#### Task #5.2: Set up pre-commit hooks
**Labels:** `task`, `sprint-0`  
**Size:** S  
**Priority:** P0  
**Time Estimate:** 30 minutes

Configure git hooks for quality checks:

**Checklist:**
- [ ] Create .pre-commit-config.yaml
- [ ] Add Go formatting checks
- [ ] Include test runner for changed files
- [ ] Add linting checks
- [ ] Configure commit message validation
- [ ] Create setup script for developers
- [ ] Document hook installation process