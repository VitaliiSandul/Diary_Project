import UIKit

class SummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICalendarViewDelegate, SummaryViewControllerDelegate {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var segmentedControl: UISegmentedControl!
    
    private var calendarView: UICalendarView!
    var viewModel = SummaryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        calendarView?.delegate = self
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        setupCalendarView()
        updateUI()
    }
    
    @objc func segmentedControlChanged() {
        let isCurrentMonth = segmentedControl.selectedSegmentIndex == 1
        viewModel.setCurrentMonthFilter(isCurrentMonth)
        updateUI()
    }
    
    private func setupCalendarView() {
        calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.delegate = self
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16)
        ])
    }
    
    func updateUI() {
        tableView?.reloadData()
        calendarView.isHidden = segmentedControl.selectedSegmentIndex != 1
        updateCalendarDecorations()
    }
    
    func updateCalendarDecorations() {
        let calendar = Calendar.current
        let dateComponents = viewModel.getEntryDates().map {
            calendar.dateComponents([.year, .month, .day], from: $0)
        }
        calendarView?.reloadDecorations(forDateComponents: dateComponents, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfStatistics()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell", for: indexPath)
        let statisticEntry = viewModel.getStatistics(for: indexPath)
        cell.textLabel?.text = statisticEntry.title
        cell.detailTextLabel?.text = statisticEntry.value
        cell.selectionStyle = .none
        return cell
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return viewModel.decorationForDateComponents(dateComponents)
    }
    
    func didUpdateDiaryEntries(_ entries: [Diary]) {
        viewModel.setEntries(entries)
        updateUI()
    }
}
