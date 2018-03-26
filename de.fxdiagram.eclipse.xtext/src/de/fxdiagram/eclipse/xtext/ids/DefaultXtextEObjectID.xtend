package de.fxdiagram.eclipse.xtext.ids

import de.fxdiagram.annotations.properties.FxProperty
import de.fxdiagram.annotations.properties.ModelNode
import java.util.NoSuchElementException
import javafx.collections.ObservableList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.XtextResource

import static javafx.collections.FXCollections.*

@ModelNode('nameSegments')
class DefaultXtextEObjectID extends AbstractXtextEObjectID {

	QualifiedName qualifiedName

	@FxProperty(readOnly=true) ObservableList<String> nameSegments = observableArrayList

	new(QualifiedName qualifiedName, EClass eClass, URI elementURI) {
		super(eClass, elementURI)
		this.qualifiedName = qualifiedName
		this.nameSegmentsProperty.setAll(qualifiedName.segments)
	}
	
	override getQualifiedName() {
		qualifiedName ?: {
			if(nameSegments.empty) null else qualifiedName = QualifiedName.create(nameSegments)
		}
	}

	override equals(Object obj) {
		if (obj instanceof DefaultXtextEObjectID)
			return super.equals(obj) &&  obj.getQualifiedName == getQualifiedName
		else
			return false
	}

	override hashCode() {
		super.hashCode + getQualifiedName.hashCode * 101 
	}

	override resolve(ResourceSet resourceSet) {
		val resourceURI = getURI.trimFragment
		val resource = resourceSet.getResource(resourceURI, true)
		if (resource === null)
			throw new NoSuchElementException('Cannot load resource ' + resourceURI)
		val resourceDescription = resourceServiceProvider.resourceDescriptionManager.
			getResourceDescription(resource)
		val eObjectDescriptions = resourceDescription.getExportedObjects(EClass, getQualifiedName(), false)
		// while editing there can be multiple named elements
//		if (eObjectDescriptions.size > 1) 
//			throw new NoSuchElementException('Expected a single element but got ' + eObjectDescriptions.size)
		if(eObjectDescriptions.empty) {
			if(resource instanceof XtextResource) {
				val extension qualifiedNameProvider = (resource as XtextResource).resourceServiceProvider.get(IQualifiedNameProvider)
				val elementByName = resource.allContents
					.filter[eClass == this.EClass]
					.findFirst[fullyQualifiedName == this.qualifiedName]
				if(elementByName !== null)
					return elementByName
			}
			throw new NoSuchElementException('''Cannot find element named «qualifiedName» of type «EClass.name» in «resource.URI»''')
		}
		val eObjectDescription = eObjectDescriptions.head
		val element = EcoreUtil.resolve(eObjectDescription.EObjectOrProxy, resource)
		if (element === null || element.eIsProxy)
			throw new NoSuchElementException('Cannot resolve element ' + eObjectDescription.EObjectURI)
		return element
	}
	
	override findInIndex(IResourceDescriptions index) {
		val resourceDescription = index.getResourceDescription(URI.trimFragment)
		if(resourceDescription === null)
			throw new NoSuchElementException('Resource ' + URI.trimFragment + ' does not exist in index')
		resourceDescription.getExportedObjects(EClass, getQualifiedName, false).head
	}

}