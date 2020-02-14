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

import com.fasterxml.jackson.annotation.JsonProperty;



@Entity
public class Card implements Serializable{

	@Id
	@GeneratedValue(strategy = GenerationType.SEQUENCE)
	private Long cardId;
	
    @JsonProperty("id")
    private String id;

    private String longNum;
    private String expires;
    private String ccv;
    
    
	public Card() {
		super();
	}


	public Card(String id, String longNum, String expires, String ccv) {
		super();
		this.id = id;
		this.longNum = longNum;
		this.expires = expires;
		this.ccv = ccv;
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
	 * @return the cardId
	 */
	public Long getCardId() {
		return cardId;
	}


	/**
	 * @param cardId the cardId to set
	 */
	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}


	/**
	 * @return the longNum
	 */
	public String getLongNum() {
		return longNum;
	}


	/**
	 * @param longNum the longNum to set
	 */
	public void setLongNum(String longNum) {
		this.longNum = longNum;
	}


	/**
	 * @return the expires
	 */
	public String getExpires() {
		return expires;
	}


	/**
	 * @param expires the expires to set
	 */
	public void setExpires(String expires) {
		this.expires = expires;
	}


	/**
	 * @return the ccv
	 */
	public String getCcv() {
		return ccv;
	}


	/**
	 * @param ccv the ccv to set
	 */
	public void setCcv(String ccv) {
		this.ccv = ccv;
	}


	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((ccv == null) ? 0 : ccv.hashCode());
		result = prime * result + ((expires == null) ? 0 : expires.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((longNum == null) ? 0 : longNum.hashCode());
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
		Card other = (Card) obj;
		if (ccv == null) {
			if (other.ccv != null)
				return false;
		} else if (!ccv.equals(other.ccv))
			return false;
		if (expires == null) {
			if (other.expires != null)
				return false;
		} else if (!expires.equals(other.expires))
			return false;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (longNum == null) {
			if (other.longNum != null)
				return false;
		} else if (!longNum.equals(other.longNum))
			return false;
		return true;
	}


	@Override
	public String toString() {
		return "Card [id=" + id + ", longNum=" + longNum + ", expires=" + expires + ", ccv=" + ccv + "]";
	}
	
	
    
    

}
