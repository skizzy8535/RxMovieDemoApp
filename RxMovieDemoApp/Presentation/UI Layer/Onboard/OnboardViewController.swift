//
//  OnboardViewController.swift
//  RxMovieDemoApp
//
//  Created by YuChen Lin on 2024/3/26.
//

import UIKit
import SnapKit

class OnboardViewController: UIPageViewController{

    private var instructionPages = [UIViewController]()

    private let skipButton = UIButton()
    private let nextButton = UIButton()
    private let pageControl = UIPageControl()
    private var scrollPage = 0

    var skipButtonTopAnchor: NSLayoutConstraint?
    var nextButtonTopAnchor: NSLayoutConstraint?
    var pageControlBottomAnchor: NSLayoutConstraint?


    override func viewDidLoad() {
        setupFlipPage()
        setPageSelectStyle()
        setLayout()
    }



    private func setupFlipPage() {
        dataSource = self
        delegate = self
        pageControl.addTarget(self, action: #selector(doTapPageControl(_:)), for: .valueChanged)

        let pageOne = InstructionViewController(imageName: "Info", titleText: "Get the Latest Movie News", subTitleText:
                                                    "You can access all movie info \n Including the lastest movie")
        let pageTwo = InstructionViewController(imageName: "OnBoardScreen", titleText: "Collect your favorite Movie", subTitleText: "After saw the info \n you can save it to  Favorites list")
        let pageThree = InstructionViewController(imageName: "Devices", titleText: "Watch On any device", subTitleText: "Watch on your phone ,table without paying more")
        let pageFour = LoginViewController()

        instructionPages.append(contentsOf: [pageOne,pageTwo,pageThree,pageFour])

        setViewControllers([instructionPages[scrollPage]], direction: .forward, animated: true)
    }

    private func setPageSelectStyle(){
        self.view.backgroundColor = .white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = AppConstant.LIGHT_SUB_COLOR
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.numberOfPages = instructionPages.count
        pageControl.currentPage = scrollPage

        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(AppConstant.LIGHT_SUB_COLOR, for: .normal)
        skipButton.addTarget(self, action: #selector(skipTapped(_ :)), for: .primaryActionTriggered)

        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(AppConstant.LIGHT_TXT_COLOR, for: .normal)
        nextButton.addTarget(self, action: #selector(nextTapped(_ :)), for: .primaryActionTriggered)
    }

    private func setLayout() {
        self.view.addSubview(pageControl)
        self.view.addSubview(skipButton)
        self.view.addSubview(nextButton)


        NSLayoutConstraint.activate([
            pageControl.widthAnchor.constraint(equalTo: view.widthAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            skipButton.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),

            view.trailingAnchor.constraint(equalToSystemSpacingAfter: nextButton.trailingAnchor, multiplier: 2),
        ])

        skipButtonTopAnchor = skipButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2)
        nextButtonTopAnchor = nextButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2)
        pageControlBottomAnchor = view.bottomAnchor.constraint(equalToSystemSpacingBelow: pageControl.bottomAnchor, multiplier: 2)

        skipButtonTopAnchor?.isActive = true
        nextButtonTopAnchor?.isActive = true
        pageControlBottomAnchor?.isActive = true
    }

    @objc func doTapPageControl(_ sender:UIPageControl) {
        setViewControllers([instructionPages[sender.currentPage]], direction: .forward, animated: true)
        doAnimateControls()
    }


    @objc func skipTapped(_ sender:UIButton) {
        let lastPageIndex = instructionPages.count - 1
        pageControl.currentPage = lastPageIndex

        goToSpecificPage(index: lastPageIndex, ofViewControllers: instructionPages)
        doAnimateControls()
    }


    @objc func nextTapped(_ sender:UIButton) {
        pageControl.currentPage += 1
        goToNextPage()
        doAnimateControls()
    }

    private func doAnimateControls() {
        let lastPage = pageControl.currentPage == instructionPages.count - 1

        if lastPage {
            hideControls()
        } else {
            showControls()
        }


        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

    }


    private func hideControls(){
        pageControlBottomAnchor?.constant = -100
        skipButtonTopAnchor?.constant = -100
        nextButtonTopAnchor?.constant = -100
    }

    private func showControls(){
        pageControlBottomAnchor?.constant = 16
        skipButtonTopAnchor?.constant = 16
        nextButtonTopAnchor?.constant = 16
    }
}



extension OnboardViewController :UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = instructionPages.firstIndex(of: viewController) else {return nil}

        if currentIndex == 0 {
            return instructionPages.last
        } else {
            return instructionPages[currentIndex - 1]
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let currentIndex = instructionPages.firstIndex(of: viewController) else { return nil}

        if currentIndex < instructionPages.count - 1 {
            return instructionPages[currentIndex + 1]
        } else {
            return instructionPages.first
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard let viewControllers = pageViewController.viewControllers else { return }
        guard let currentIndex = instructionPages.firstIndex(of: viewControllers[0]) else { return }

        pageControl.currentPage = currentIndex
        doAnimateControls()
    }

}


extension OnboardViewController {

    func goToNextPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let nextPage = dataSource?.pageViewController(self, viewControllerAfter: currentPage) else { return }

        setViewControllers([nextPage], direction: .forward, animated: animated, completion: completion)
    }

    func goToPreviousPage(animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let currentPage = viewControllers?[0] else { return }
        guard let prevPage = dataSource?.pageViewController(self, viewControllerBefore: currentPage) else { return }

        setViewControllers([prevPage], direction: .forward, animated: animated, completion: completion)
    }

    func goToSpecificPage(index: Int, ofViewControllers pages: [UIViewController]) {
        setViewControllers([pages[index]], direction: .forward, animated: true, completion: nil)
    }
}
