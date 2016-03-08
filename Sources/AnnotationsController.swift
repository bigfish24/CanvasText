//
//  AnnotationsController.swift
//  CanvasText
//
//  Created by Sam Soffes on 3/7/16.
//  Copyright © 2016 Canvas Labs, Inc. All rights reserved.
//

import UIKit
import CanvasNative

protocol AnnotationsControllerDelegate: class {
	func annotationsController(annotationsController: AnnotationsController, willAddAnnotation annotation: View)
}

final class AnnotationsController {

	// MARK: - Properties

	var theme: Theme {
		didSet {
			for annotation in annotations {
				annotation?.theme = theme
			}
		}
	}

	weak var delegate: AnnotationsControllerDelegate?
	weak var textController: TextController?

	private var annotations = [Annotation?]()


	// MARK: - Initializers

	init(theme: Theme) {
		self.theme = theme
	}


	// MARK: - Manipulating

	func insert(block block: BlockNode, index: Int) {
		guard let block = block as? Annotatable, annotation = annotationForBlock(block) else {
			annotations.insert(nil, atIndex: index)
			return
		}

		annotation.frame = rectForAnnotation(annotation, index: index)
		annotations.insert(annotation, atIndex: index)
		delegate?.annotationsController(self, willAddAnnotation: annotation)
	}

	func remove(block block: BlockNode, index: Int) {
		annotations.removeAtIndex(index)
	}

	func replace(block block: BlockNode, index: Int) {
		update(block: block, index: index)
	}

	func update(block block: BlockNode, index: Int) {
		guard let annotation = annotations[index] else { return }
		annotation.frame = rectForAnnotation(annotation, index: index)
	}


	// MARK: - Layout

	func layoutAnnotations() {
		for (index, annotation) in annotations.enumerate() {
			guard let annotation = annotation else { continue }
			annotation.frame = rectForAnnotation(annotation, index: index)
		}
	}

	func rectForAnnotation(annotation: Annotation, index: Int) -> CGRect {
		guard let textController = textController else { return .zero }

		let presentationRange = textController.canvasController.presentationRange(backingRange: annotation.block.enclosingRange)
		let glyphIndex = textController.layoutManager.glyphIndexForCharacterAtIndex(presentationRange.location)
		var rect = textController.layoutManager.lineFragmentUsedRectForGlyphAtIndex(glyphIndex, effectiveRange: nil, withoutAdditionalLayout: true)

		// No idea why this is required *sigh*
		rect.origin.y += 8

		let size = annotation.intrinsicContentSize()
//		rect.origin.x -= size.width
		rect.origin.y += floor((rect.size.height - size.height) / 2)
		rect.size = size

		return rect
	}


	// MARK: - Private

	private func annotationForBlock(block: Annotatable) -> Annotation? {
		if block is UnorderedListItem {
			return BulletView(block: block, theme: theme)
		}

		// TODO: Implement additional types
		return nil
	}
}