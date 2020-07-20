//
//  TweetCell.swift
//  SkovTwitter
//
//  Created by Oleksandr Kovalyshyn on 08.05.2020.
//  Copyright © 2020 Oleksandr Kovalyshyn. All rights reserved.
//

import UIKit
import ActiveLabel

protocol TweetCellDelegate: class {
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleFetchUser(withUsername username: String)
}

class TweetCell: UICollectionViewCell {
    
    // MARK: - Properties

    var tweet: Tweet? {
        didSet { configure() }
    }
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.setDimensions(width: 54, height: 54)
        iv.layer.cornerRadius = 54 / 2
        iv.backgroundColor = .twitterBlue
        iv.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        iv.layer.borderWidth = 1
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        iv.addGestureRecognizer(tap)
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        
        return label
    }()
    
    private let infoLabel = UILabel()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        
        return button
    }()

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel, captionLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let imageCaptionStack = UIStackView(arrangedSubviews: [profileImageView, captionStack])
        imageCaptionStack.distribution = .fillProportionally
        imageCaptionStack.spacing = 12
        imageCaptionStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageCaptionStack])
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                     paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        
        infoLabel.font = UIFont.systemFont(ofSize: 15)
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton, retweetButton,
                                                         likeButton, shareButton])
        actionStack.axis = .horizontal
        actionStack.spacing = 72
        addSubview(actionStack)
        actionStack.centerX(inView: self)
        actionStack.anchor(bottom: bottomAnchor, paddingBottom: 8)
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor,
                             right: rightAnchor, height: 1)
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
        print("🎁")
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleRetweetTapped() {
        
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
    }
    
    @objc func handleShareTapped() {
        
    }

    // MARK: - Helpers
    
    func configure() {
        guard let tweet = tweet else { return }
        let viewModel = TweetViewModel(tweet: tweet)
            
        profileImageView.sd_setImage(with: viewModel.profileImageURL, completed: nil)
        captionLabel.text = viewModel.tweet.caption
        infoLabel.attributedText = viewModel.userInfoText
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyLabelText
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { [weak self] username in
            guard let self = self else { return }
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        
        return button
    }
    
}
