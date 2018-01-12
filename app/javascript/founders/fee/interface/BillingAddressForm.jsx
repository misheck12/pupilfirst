import React from "react";
import PropTypes from "prop-types";

export default class BillingAddressForm extends React.Component {
  constructor(props) {
    super(props);

    this.updateAddress = this.updateAddress.bind(this);
    this.updateState = this.updateState.bind(this);
  }

  stateOptions() {
    return this.props.states.map(state => {
      return (
        <option key={state.id} value={state.id}>
          {state.name}
        </option>
      );
    });
  }

  billingAddress() {
    const currentAddress = this.props.rootState.startup.billingAddress;
    return _.isString(currentAddress) ? currentAddress : "";
  }

  selectedState() {
    const billingStateId = this.props.rootState.startup.billingStateId;
    return _.isNumber(billingStateId) ? "" + billingStateId : "";
  }

  updateAddress(event) {
    const startupClone = _.cloneDeep(this.props.rootState.startup);
    startupClone.billingAddress = event.target.value;
    this.props.setRootState({ startup: startupClone });
  }

  updateState(event) {
    const startupClone = _.cloneDeep(this.props.rootState.startup);
    startupClone.billingStateId = parseInt(event.target.value);
    this.props.setRootState({ startup: startupClone });
  }

  render() {
    return (
      <div className="content-box">
        <div className="form-group">
          <label
            className="form-control-label"
            htmlFor="billing-address-form__address"
          >
            Billing address
          </label>
          <textarea
            required="required"
            placeholder="House Number,
                Street Name,
                Locality,
                City.
                "
            rows="4"
            className="form-control"
            id="billing-address-form__address"
            value={this.billingAddress()}
            onChange={this.updateAddress}
          />
        </div>
        <div className="form-group">
          <label
            className="col-form-label form-control-label"
            htmlFor="billing-address-form__state"
          >
            Billing state
          </label>
          <select
            required="required"
            className="form-control"
            id="billing-address-form__state"
            value={this.selectedState()}
            onChange={this.updateState}
          >
            <option value="">Select your State</option>
            {this.stateOptions()}
          </select>
        </div>
      </div>
    );
  }
}

BillingAddressForm.propTypes = {
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  states: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string
    })
  )
};
