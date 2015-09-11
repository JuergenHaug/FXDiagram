package de.fxdiagram.lib.nodes

import de.fxdiagram.annotations.properties.FxProperty
import de.fxdiagram.annotations.properties.ModelNode
import de.fxdiagram.core.behavior.AbstractReconcileBehavior
import de.fxdiagram.core.behavior.ReconcileBehavior
import de.fxdiagram.core.behavior.UpdateAcceptor
import de.fxdiagram.core.command.AbstractCommand
import de.fxdiagram.core.command.CommandContext
import de.fxdiagram.core.command.SequentialAnimationCommand
import de.fxdiagram.core.model.DomainObjectDescriptor
import de.fxdiagram.lib.anchors.RoundedRectangleAnchors
import de.fxdiagram.lib.animations.Inflator
import java.util.NoSuchElementException
import javafx.animation.Animation
import javafx.animation.KeyFrame
import javafx.animation.KeyValue
import javafx.animation.Timeline
import javafx.beans.property.BooleanProperty
import javafx.collections.ObservableList
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.geometry.VPos
import javafx.scene.control.CheckBox
import javafx.scene.control.ColorPicker
import javafx.scene.control.Label
import javafx.scene.layout.VBox
import javafx.scene.paint.Color
import javafx.scene.text.Font
import javafx.scene.text.FontWeight
import javafx.scene.text.Text
import org.eclipse.xtend.lib.annotations.Accessors

import static de.fxdiagram.core.behavior.DirtyState.*
import static javafx.collections.FXCollections.*

import static extension de.fxdiagram.core.extensions.DurationExtensions.*
import static extension de.fxdiagram.core.extensions.TooltipExtensions.*

@ModelNode("showPackage", "showAttributes", "showMethods", "bgColor", "model")
abstract class AbstractClassNode extends FlipNode {

	@FxProperty boolean showPackage = false
	@FxProperty boolean showAttributes = true
	@FxProperty boolean showMethods = true
	@FxProperty Color bgColor
	@FxProperty ClassModel model

	CheckBox packageBox
	CheckBox attributesBox
	CheckBox methodsBox

	VBox contentArea
	VBox packageArea
	VBox attributeCompartment
	VBox methodCompartment
	Text nameLabel
	Label fileLabel

	@Accessors(PUBLIC_GETTER) Inflator inflator

	new(DomainObjectDescriptor descriptor) {
		super(descriptor)
	}

	def getDefaultBgPaint() {
		Color.web('#ffe6cc')
	}

	override createNode() {
		val pane = super.createNode
		bgColor = defaultBgPaint
		front = new RectangleBorderPane => [
			tooltip = 'Right-click to configure'
			backgroundPaintProperty.bind(bgColorProperty)
			children += contentArea = new VBox => [
				padding = new Insets(10, 20, 10, 20)
				children += new VBox => [
					alignment = Pos.CENTER
					children += nameLabel = new Text => [
						textOrigin = VPos.TOP
						font = Font.font(font.family, FontWeight.BOLD, font.size * 1.1)
					]
				]
			]
		]
		back = new RectangleBorderPane => [
			tooltip = 'Right-click to show node'
			backgroundPaintProperty.bind(bgColorProperty)
			children += new VBox => [
				padding = new Insets(10, 20, 10, 20)
				spacing = 5
				children += fileLabel = new Label
				children += packageBox = new CheckBox('Package')
				children += attributesBox = new CheckBox('Attributes')
				children += methodsBox = new CheckBox('Methods')
				children += new ColorPicker => [
					valueProperty.bindBidirectional(bgColorProperty)
				]
			]
		]
		inflator = new Inflator(this, contentArea)
		packageArea = new VBox => [
			alignment = Pos.CENTER
			addInflatable(showPackageProperty, packageBox, 0, inflator)
		]
		attributeCompartment = new VBox => [ c |
			c.padding = new Insets(10, 0, 0, 0)
			c.addInflatable(showAttributesProperty, attributesBox, contentArea.children.size, inflator)
		]
		methodCompartment = new VBox => [ c |
			c.padding = new Insets(10, 0, 0, 0)
			c.addInflatable(showMethodsProperty, methodsBox, contentArea.children.size, inflator)
		]
		if(model == null)
			model = inferClassModel
		populateFromModel
		modelProperty.addListener [ p, o, n |
			populateFromModel
		]
		pane
	}
	
	def populateFromModel() {
		nameLabel.text = model.name
		fileLabel.text = model.fileName
		packageArea.children.clear
		packageArea.children += new Text => [
			textOrigin = VPos.TOP
			font = Font.font(font.family, font.size * 0.8)
			text = model.namespace
		]
		attributeCompartment.children.clear
		model.attributes.forEach [ field |
			attributeCompartment.children += new Text => [
				textOrigin = VPos.TOP
				text = field
			]
		]
		methodCompartment.children.clear
		model.operations.forEach [ operation |
			methodCompartment.children += new Text => [
				textOrigin = VPos.TOP
				text = operation
			]
		]
	}

	override protected createAnchors() {
		new RoundedRectangleAnchors(this, 6, 6)
	}

	override doActivate() {
		super.doActivate()
		addBehavior(new ClassModelReconcileBehavior(this))
		showPackageProperty.bindCheckbox(packageBox, packageArea, [0], inflator)
		showAttributesProperty.bindCheckbox(attributesBox, attributeCompartment, [if(showPackage) 2 else 1], inflator)
		showMethodsProperty.bindCheckbox(methodsBox, methodCompartment, [contentArea.children.size], inflator)
		inflator.inflateAnimation?.play
	}

	override getAutoLayoutDimension() {
		inflator.inflatedSize
	}

	protected def addInflatable(VBox compartment, BooleanProperty showProperty, CheckBox box, int index,
		Inflator inflator) {
		if (showProperty.get)
			inflator.addInflatable(compartment, index)
	}

	protected def bindCheckbox(BooleanProperty property, CheckBox box, VBox compartment, ()=>int index,
		Inflator inflator) {
		box.selectedProperty.bindBidirectional(property)
		property.addListener [ p, o, show |
			if (contentArea.children.contains(compartment)) {
				if (!show)
					inflator.removeInflatable(compartment)
			} else {
				if (show)
					inflator.addInflatable(compartment, index.apply)
			}
		]
	}

	abstract def ClassModel inferClassModel()

	protected def createMorphCommand(ClassModel newModel) {
		val oldModel = model
		new SequentialAnimationCommand => [
			it += inflator.deflateCommand
			it += new AbstractCommand() {
				override execute(CommandContext context) {
					model = newModel
					getBehavior(ReconcileBehavior).showDirtyState(CLEAN)
				}
				
				override undo(CommandContext context) {
					model = oldModel
					getBehavior(ReconcileBehavior).showDirtyState(DIRTY)
				}
				
				override redo(CommandContext context) {
					model= newModel
					getBehavior(ReconcileBehavior).showDirtyState(CLEAN)
				}
			}
			it += inflator.inflateCommand
		]
	}
}


@ModelNode('namespace', 'name', 'attributes', 'operations')
class ClassModel {
	@FxProperty String namespace = '<default>'
	@FxProperty String name
	@FxProperty String fileName
	@FxProperty ObservableList<String> attributes = observableArrayList
	@FxProperty ObservableList<String> operations = observableArrayList

	override equals(Object other) {
		if (other instanceof ClassModel)
			return namespace == other.namespace && name == other.name && fileName == other.fileName &&
				attributes == other.attributes && operations == other.operations
		else
			return false
	}
}


class ClassModelReconcileBehavior extends AbstractReconcileBehavior<AbstractClassNode> {

	@FxProperty double dirtyAnimationValue
	@FxProperty double dirtyAnimationRotate

	Animation dirtyAnimation

	new(AbstractClassNode host) {
		super(host)
	}

	override getDirtyState() {
		try {
			val newModel = host.inferClassModel
			if (newModel == null)
				DANGLING
			else if (host.model != newModel)
				DIRTY
			else
				CLEAN
		} catch (NoSuchElementException exc) {
			return DANGLING
		}
	}

	override protected doActivate() {
		dirtyAnimation = new Timeline => [
			keyFrames += new KeyFrame(0.millis, new KeyValue(dirtyAnimationValueProperty, 1))
			keyFrames += new KeyFrame(300.millis, new KeyValue(dirtyAnimationValueProperty, 0.96))
			keyFrames += new KeyFrame(900.millis, new KeyValue(dirtyAnimationValueProperty, 1.04))
			keyFrames += new KeyFrame(1200.millis, new KeyValue(dirtyAnimationValueProperty, 1))
			autoReverse = true
			cycleCount = Animation.INDEFINITE
		]
	}
	
	override protected dirtyFeedback(boolean isDirty) {
		if(isDirty) {
			host => [ 
				scaleXProperty.bind(dirtyAnimationValueProperty)
				scaleYProperty.bind(dirtyAnimationValueProperty)
			]
			dirtyAnimation.play
		} else {
			host => [ 
				scaleXProperty.unbind
				scaleYProperty.unbind
				scaleX = 1
				scaleY = 1
			]	
			dirtyAnimation.stop
		}
	}
	
	override reconcile(UpdateAcceptor acceptor) {
		try {
			val newModel = host.inferClassModel
			if (newModel != null) {
				if (host.model != newModel)
					acceptor.morph(host.createMorphCommand(newModel))
				return
			}
		} catch (NoSuchElementException exc) {
			// fallthrough
		}
		acceptor.delete(host)
	}
}

