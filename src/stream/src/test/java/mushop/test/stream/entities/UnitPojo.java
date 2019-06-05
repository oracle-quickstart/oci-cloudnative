package mushop.test.stream.entities;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.junit.Assert.assertThat;

import java.util.List;

import org.junit.Test;

import com.openpojo.reflection.PojoClass;
import com.openpojo.reflection.PojoClassFilter;
import com.openpojo.reflection.filters.FilterClassName;
import com.openpojo.reflection.impl.PojoClassFactory;
import com.openpojo.validation.Validator;
import com.openpojo.validation.ValidatorBuilder;
import com.openpojo.validation.affirm.Affirm;
import com.openpojo.validation.rule.impl.GetterMustExistRule;
import com.openpojo.validation.rule.impl.NoFieldShadowingRule;
import com.openpojo.validation.rule.impl.NoPublicFieldsExceptStaticFinalRule;
import com.openpojo.validation.rule.impl.NoStaticExceptFinalRule;
import com.openpojo.validation.rule.impl.SetterMustExistRule;
import com.openpojo.validation.test.impl.GetterTester;
import com.openpojo.validation.test.impl.SetterTester;

import mushop.stream.entities.Shipment;

public class UnitPojo {
    // Configured for expectation, so we know when a class gets added or removed.
    private static final int EXPECTED_CLASS_COUNT = 1;

    // The package to test
    private static final String POJO_PACKAGE = "oracle.ateam.socks.shipping.entities";

    private final PojoClassFilter filter = new FilterClassName("^((?!Unit).)*$");

    @Test
    public void ensureExpectedPojoCount() {
        List<PojoClass> pojoClasses = PojoClassFactory.getPojoClasses(POJO_PACKAGE, filter);
        Affirm.affirmEquals("Classes added / removed?", EXPECTED_CLASS_COUNT, pojoClasses.size());
    }

    @Test
    public void testPojoStructureAndBehavior() {
        Validator validator = ValidatorBuilder.create()
                // Add Rules to validate structure for POJO_PACKAGE
                // See com.openpojo.validation.rule.impl for more ...
                .with(new GetterMustExistRule())
                .with(new SetterMustExistRule())
                // Add Testers to validate behaviour for POJO_PACKAGE
                // See com.openpojo.validation.test.impl for more ...
                .with(new SetterTester())
                .with(new GetterTester())
                // Static fields must be final
                .with(new NoStaticExceptFinalRule())
                // Don't shadow parent's field names.
                .with(new NoFieldShadowingRule())
                // What about public fields, use one of the following rules
                // allow them only if they are static and final.
                .with(new NoPublicFieldsExceptStaticFinalRule())
                .build();

        validator.validate(POJO_PACKAGE, filter);
    }

    @Test
    public void testEquals() throws Exception {
        assertThat(new Shipment("id", "name"), is(equalTo(new Shipment("id", "name"))));
        assertThat(new Shipment("id", "name"), is(equalTo(new Shipment("id", "another"))));
        assertThat(new Shipment("id", "name"), is(not(equalTo(new Shipment("another", "name")))));
    }

    @Test
    public void testHashcode() throws Exception {
        assertThat(new Shipment("id", "name").hashCode(), is(equalTo(new Shipment("id", "name").hashCode())));
        assertThat(new Shipment("id", "name").hashCode(), is(equalTo(new Shipment("id", "another").hashCode())));
        assertThat(new Shipment("id", "name").hashCode(), is(not(equalTo(new Shipment("aa", "name").hashCode()))));
    }

    @Test
    public void testString() throws Exception {
        assertThat(new Shipment("id").toString(), is(notNullValue()));

    }
    
}
