import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.DockerClientFactory;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.utility.LogUtils;

import helpers.DockerImageTagResolver;

import io.homecentr.testcontainers.containers.GenericContainerEx;
import io.homecentr.testcontainers.containers.wait.strategy.WaitEx;

public abstract class ContainerShould {
    private static final Logger logger = LoggerFactory.getLogger(ContainerShould.class);

    private static GenericContainerEx _container;

    @BeforeClass
    public static void setUp() {
        _container = new GenericContainerEx<>(new DockerImageTagResolver())
                .waitingFor(WaitEx.forS6OverlayStart());

        _container.start();
        LogUtils.followOutput(DockerClientFactory.instance().client(), _container.getContainerId(), new Slf4jLogConsumer(logger));
    }

    @AfterClass
    public static void cleanUp() {
        _container.close();
    }

    @Test
    public void doSomething() throws Exception {
        throw new Exception("Implement the test");
    }
}