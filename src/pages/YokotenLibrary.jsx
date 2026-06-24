import { BookOpenCheck, CalendarDays, MapPin, Paperclip, Share2 } from 'lucide-react'
import { useMemo, useState } from 'react'
import { PageHeader, StatusBadge } from '../components/UI'
import { useYokoten } from '../yokoten/YokotenContext'

export default function YokotenLibrary() {
  const { stories } = useYokoten()
  const [filters, setFilters] = useState({ department: 'All', location: 'All', category: 'All', date: '' })
  const options = key => ['All', ...new Set(stories.map(story => story[key]).filter(Boolean))]
  const visibleStories = useMemo(() => stories.filter(story =>
    (filters.department === 'All' || story.department === filters.department) &&
    (filters.location === 'All' || story.location === filters.location) &&
    (filters.category === 'All' || story.category === filters.category) &&
    (!filters.date || story.createdAt === filters.date)
  ), [stories, filters])

  function updateFilter(key, value) {
    setFilters(current => ({ ...current, [key]: value }))
  }

  return <>
    <PageHeader eyebrow="CONTINUOUS IMPROVEMENT" title="Yokoten Library" description="Share proven countermeasures and successful improvements across departments and locations." />
    <section className="card yokoten-filter-bar">
      <label>Department<select value={filters.department} onChange={event => updateFilter('department', event.target.value)}>{options('department').map(option => <option key={option}>{option}</option>)}</select></label>
      <label>Location<select value={filters.location} onChange={event => updateFilter('location', event.target.value)}>{options('location').map(option => <option key={option}>{option}</option>)}</select></label>
      <label>Category<select value={filters.category} onChange={event => updateFilter('category', event.target.value)}>{options('category').map(option => <option key={option}>{option}</option>)}</select></label>
      <label>Date<input type="date" value={filters.date} onChange={event => updateFilter('date', event.target.value)} /></label>
      <button className="secondary-button" onClick={() => setFilters({ department: 'All', location: 'All', category: 'All', date: '' })}>Clear Filters</button>
    </section>
    <div className="yokoten-library-summary"><strong>{visibleStories.length}</strong><span>success stories available</span></div>
    {visibleStories.length === 0 ? <section className="card yokoten-empty"><BookOpenCheck /><h2>No Yokoten stories found</h2><p>Adjust the filters or publish an approved improvement from Improvement Detail.</p></section> : <div className="yokoten-card-grid">{visibleStories.map(story => <article className="card yokoten-story-card" key={story.id}>
      <div className="yokoten-card-head"><span className="yokoten-icon"><Share2 /></span><div><small>{story.id}</small><h2>{story.improvementTitle}</h2></div><StatusBadge>{story.approvalStatus}</StatusBadge></div>
      <div className="yokoten-card-meta"><span><MapPin /> {story.location}</span><span>{story.department}</span><span>{story.category}</span><span><CalendarDays /> {story.sharedDate}</span></div>
      <div className="yokoten-story-section"><strong>Original Finding</strong><p>{story.originalFinding}</p></div>
      <div className="yokoten-story-section highlight"><strong>Countermeasure Implemented</strong><p>{story.countermeasureImplemented}</p></div>
      <div className="yokoten-benefit"><BookOpenCheck /><span><strong>Benefits Achieved</strong><p>{story.benefitsAchieved}</p></span></div>
      <div className="yokoten-applicable"><strong>Can Be Applied To</strong><div>{story.appliedTo.map(item => <span key={item}>{item}</span>)}</div></div>
      <div className="yokoten-attachments"><Paperclip /><span>{story.attachments.length ? `${story.attachments.length} attachment${story.attachments.length > 1 ? 's' : ''}` : 'No attachments'}</span><small>{story.sourceImprovementId}</small></div>
    </article>)}</div>}
  </>
}
