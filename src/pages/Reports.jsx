import { Component } from 'react'
import ReportsDashboard from './ReportsDashboard'

class ReportsErrorBoundary extends Component {
  constructor(props) {
    super(props)
    this.state = { error: null }
  }

  static getDerivedStateFromError(error) {
    return { error }
  }

  render() {
    if (this.state.error) {
      return <section className="card report-error"><strong>Reports dashboard failed to render</strong><p>{this.state.error.message}</p></section>
    }
    return this.props.children
  }
}

export default function Reports() {
  return <ReportsErrorBoundary><ReportsDashboard /></ReportsErrorBoundary>
}
