/**
 ** Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 ** Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
 **/
package  mushop.orders.entities;


import java.io.Serializable;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.validation.constraints.NotNull;

import com.fasterxml.jackson.annotation.JsonProperty;


@Entity
public class Item implements Serializable{
	
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    private Long sId;
    
    @JsonProperty("id")
    private String id;

    @NotNull(message = "Item name must not be null")
    private String itemId;
    private int quantity;
    private float unitPrice;
	public Item() {
		this(null, "", 1, 0F);
	}
	public Item(String id, @NotNull(message = "Item Id must not be null") String itemId, int quantity, float unitPrice) {
		super();
		this.id = id;
		this.itemId = itemId;
		this.quantity = quantity;
		this.unitPrice = unitPrice;
	}
	
	
	/**
	 * @return the sId
	 */
	public Long getsId() {
		return sId;
	}
	/**
	 * @param sId the sId to set
	 */
	public void setsId(Long sId) {
		this.sId = sId;
	}
	/**
	 * @return the id
	 */
	public String getId() {
		return id;
	}
	/**
	 * @param id the id to set
	 */
	public void setId(String id) {
		this.id = id;
	}
	/**
	 * @return the name
	 */
	public String getItemId() {
		return itemId;
	}
	/**
	 * @param name the name to set
	 */
	public void setItemId(String itemId) {
		this.itemId = itemId;
	}
	/**
	 * @return the quantity
	 */
	public int getQuantity() {
		return quantity;
	}
	/**
	 * @param quantity the quantity to set
	 */
	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}
	/**
	 * @return the unitPrice
	 */
	public float getUnitPrice() {
		return unitPrice;
	}
	/**
	 * @param unitPrice the unitPrice to set
	 */
	public void setUnitPrice(float unitPrice) {
		this.unitPrice = unitPrice;
	}
	
	public float getTotal() {
		return this.unitPrice*this.quantity;
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((itemId == null) ? 0 : itemId.hashCode());
		result = prime * result + quantity;
		result = prime * result + Float.floatToIntBits(unitPrice);
		return result;
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Item other = (Item) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (itemId == null) {
			if (other.itemId != null)
				return false;
		} else if (!itemId.equals(other.itemId))
			return false;
		if (quantity != other.quantity)
			return false;
		if (Float.floatToIntBits(unitPrice) != Float.floatToIntBits(other.unitPrice))
			return false;
		return true;
	}
	@Override
	public String toString() {
		return "Item [id=" + id + ", itemId=" + itemId + ", quantity=" + quantity + ", unitPrice=" + unitPrice + "]";
	}
    
    

}
