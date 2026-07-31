import { Controller } from "@hotwired/stimulus"
import Chart from "chart.js/auto"

// Dashboard charts rendered via Chart.js
// Usage: <div data-controller="dashboard-charts" data-dashboard-charts-data-value="...JSON...">
export default class extends Controller {
  static values = { data: Object }

  connect() {
    this.renderCharts()
  }

  renderCharts() {
    const d = this.dataValue
    if (!d) return

    this.renderPassFailChart(d.test_result_distribution)
    this.renderJobStatusChart(d.job_status_distribution)
    this.renderWorkerStatusChart(d.worker_status_distribution)
    this.renderTrendChart(d.trend_data)
  }

  renderPassFailChart(dist) {
    const ctx = document.getElementById("chart-pass-fail")
    if (!ctx) return

    const labels = Object.keys(dist)
    const values = Object.values(dist)
    const colors = {
      Passed: "#16a34a", Failed: "#dc2626", Error: "#e11d48",
      Skipped: "#9ca3af", Pending: "#f59e0b"
    }

    new Chart(ctx, {
      type: "doughnut",
      data: {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: labels.map(l => colors[l] || "#6b7280"),
          borderWidth: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: "bottom", labels: { padding: 16, usePointStyle: true } },
          title: { display: true, text: "Test Results", font: { size: 14, weight: "600" } }
        }
      }
    })
  }

  renderJobStatusChart(dist) {
    const ctx = document.getElementById("chart-job-status")
    if (!ctx) return

    const labels = Object.keys(dist)
    const values = Object.values(dist)
    const colors = {
      Pending: "#f59e0b", Queued: "#8b5cf6", Running: "#3b82f6",
      Completed: "#16a34a", Failed: "#dc2626", Cancelled: "#9ca3af"
    }

    new Chart(ctx, {
      type: "bar",
      data: {
        labels: labels,
        datasets: [{
          label: "Jobs",
          data: values,
          backgroundColor: labels.map(l => colors[l] || "#6b7280"),
          borderRadius: 4,
          borderWidth: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { beginAtZero: true, ticks: { stepSize: 1 } }
        },
        plugins: {
          legend: { display: false },
          title: { display: true, text: "Job Status", font: { size: 14, weight: "600" } }
        }
      }
    })
  }

  renderWorkerStatusChart(dist) {
    const ctx = document.getElementById("chart-worker-status")
    if (!ctx) return

    const labels = Object.keys(dist)
    const values = Object.values(dist)
    const colors = {
      Idle: "#16a34a", Busy: "#3b82f6", Offline: "#9ca3af", Maintenance: "#f59e0b"
    }

    new Chart(ctx, {
      type: "doughnut",
      data: {
        labels: labels,
        datasets: [{
          data: values,
          backgroundColor: labels.map(l => colors[l] || "#6b7280"),
          borderWidth: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: "bottom", labels: { padding: 16, usePointStyle: true } },
          title: { display: true, text: "Worker Status", font: { size: 14, weight: "600" } }
        }
      }
    })
  }

  renderTrendChart(data) {
    const ctx = document.getElementById("chart-trend")
    if (!ctx || !data) return

    new Chart(ctx, {
      type: "line",
      data: {
        labels: data.map(d => d.date),
        datasets: [{
          label: "Pass Rate %",
          data: data.map(d => d.pass_rate),
          borderColor: "#16a34a",
          backgroundColor: "rgba(22,163,74,0.1)",
          fill: true,
          tension: 0.3,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { min: 0, max: 100, ticks: { callback: v => v + "%" } }
        },
        plugins: {
          legend: { display: false },
          title: { display: false }
        }
      }
    })
  }
}
